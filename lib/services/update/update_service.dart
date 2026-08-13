import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../app/routes/app_routes.dart';
import '../../core/base/base_service.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/utils/version_utils.dart';
import '../../data/models/update/release_info.dart';
import '../../data/models/update/update_history_entry.dart';
import '../../data/models/update/update_progress.dart';
import '../../data/repositories/update_repository.dart';
import '../notification/notification_service.dart';
import '../settings/settings_service.dart';
import 'apk_download_manager.dart';
import 'github_release_client.dart';

/// In-app APK update orchestration (SRS §28).
class UpdateService extends GetxService with BaseService {
  UpdateService(
    this._settings,
    this._github,
    this._downloader,
    this._repository,
    this._notifications,
  );

  final SettingsService _settings;
  final GitHubReleaseClient _github;
  final ApkDownloadManager _downloader;
  final UpdateRepository _repository;
  final NotificationService _notifications;

  final Rxn<ReleaseInfo> availableUpdate = Rxn<ReleaseInfo>();
  final Rxn<UpdateProgress> progress = Rxn<UpdateProgress>();
  final RxString currentVersion = ''.obs;
  final RxString currentBuild = ''.obs;

  ReleaseInfo? _pendingRelease;
  File? _downloadedApk;
  DateTime? _lastProgressNotificationAt;

  Future<UpdateService> init() async {
    final info = await PackageInfo.fromPlatform();
    currentVersion.value = info.version;
    currentBuild.value = info.buildNumber;
    _notifications.onNotificationTapped = _onNotificationTapped;
    return this;
  }

  Future<ServiceResult<ReleaseInfo?>> checkForUpdate({bool manual = false}) async {
    return guard(() async {
      progress.value = const UpdateProgress(phase: UpdateDownloadPhase.checking);
      try {
        final release = await _github.fetchLatestRelease();
        await _settings.recordUpdateCheck(at: DateTime.now());

        if (release == null ||
            !VersionUtils.isNewer(release.version, currentVersion.value)) {
          availableUpdate.value = null;
          progress.value = const UpdateProgress(phase: UpdateDownloadPhase.idle);
          return null;
        }

        availableUpdate.value = release;
        _pendingRelease = release;
        progress.value = const UpdateProgress(phase: UpdateDownloadPhase.idle);
        return release;
      } catch (error) {
        progress.value = const UpdateProgress(phase: UpdateDownloadPhase.failed);
        rethrow;
      }
    });
  }

  Future<void> maybeCheckOnLaunch() async {
    if (!_settings.autoUpdateCheckEnabled.value) return;
    if (!_settings.isUpdateCheckDue) return;

    final result = await checkForUpdate(manual: false);
    if (result.isFailure) {
      log.w('Background update check failed: ${result.userMessage}');
      progress.value = const UpdateProgress(phase: UpdateDownloadPhase.idle);
    }
  }

  /// Handles a notification tap that started the process. Call after navigation
  /// is ready. Returns true when the update screen / installer was opened.
  Future<bool> handlePendingNotificationLaunch() async {
    final payload = _notifications.takePendingLaunchPayload();
    if (payload == null || payload.isEmpty) return false;

    if (payload == NotificationService.updateInstallPayload) {
      await installDownloadedApk();
      return true;
    }
    if (payload == NotificationService.updateOpenPayload) {
      if (Get.currentRoute != AppRoutes.update) {
        await Get.toNamed<void>(AppRoutes.update);
      }
      return true;
    }
    return false;
  }

  Future<ServiceResult<void>> downloadAvailableUpdate() async {
    final release = _pendingRelease ?? availableUpdate.value;
    if (release == null) {
      return ServiceResult.failure(
        userMessage: 'No update available to download',
        errorCode: 'UPDATE_NOT_AVAILABLE',
      );
    }

    return guardVoid(() async {
      await _runDownload(release);
    });
  }

  Future<void> _runDownload(ReleaseInfo release) async {
    try {
      await _notifications.requestPermissions();

      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'updates', release.apkFileName));
      if (await file.parent.exists() == false) {
        await file.parent.create(recursive: true);
      }

      _lastProgressNotificationAt = null;
      await _notifications.showUpdateDownloadProgress(
        version: release.version,
        progress: 0,
        maxProgress: 100,
        indeterminate: release.apkSizeBytes <= 0,
      );

      await _downloader.download(
        release: release,
        target: file,
        onProgress: (value) => _onDownloadProgress(release, value),
      );

      final length = await file.length();
      progress.value = UpdateProgress(
        phase: UpdateDownloadPhase.readyToInstall,
        receivedBytes: length,
        totalBytes: length,
      );
      _downloadedApk = file;
      await _notifications.showUpdateReadyToInstall(version: release.version);
    } catch (error) {
      final current = progress.value;
      progress.value = UpdateProgress(
        phase: UpdateDownloadPhase.failed,
        receivedBytes: current?.receivedBytes ?? 0,
        totalBytes: current?.totalBytes ?? 0,
      );
      final cancelled = error is UpdateException &&
          error.code == 'UPDATE_DOWNLOAD_CANCELLED';
      if (!cancelled) {
        await _notifications.showUpdateDownloadFailed(version: release.version);
      }
      rethrow;
    }
  }

  void _onDownloadProgress(ReleaseInfo release, UpdateProgress value) {
    progress.value = value;

    final force = value.phase != UpdateDownloadPhase.downloading;
    final now = DateTime.now();
    if (!force &&
        _lastProgressNotificationAt != null &&
        now.difference(_lastProgressNotificationAt!) <
            const Duration(milliseconds: 500)) {
      return;
    }
    _lastProgressNotificationAt = now;

    final percent = (value.percent * 100).round().clamp(0, 100);
    unawaited(
      _notifications.showUpdateDownloadProgress(
        version: release.version,
        progress: percent,
        maxProgress: 100,
        paused: value.phase == UpdateDownloadPhase.paused,
        indeterminate: value.totalBytes <= 0,
      ),
    );
  }

  void pauseDownload() {
    _downloader.pause();
    final current = progress.value;
    if (current != null) {
      progress.value = UpdateProgress(
        phase: UpdateDownloadPhase.paused,
        receivedBytes: current.receivedBytes,
        totalBytes: current.totalBytes,
        speedBytesPerSecond: current.speedBytesPerSecond,
      );
      final release = _pendingRelease ?? availableUpdate.value;
      if (release != null) {
        unawaited(
          _notifications.showUpdateDownloadProgress(
            version: release.version,
            progress: (current.percent * 100).round().clamp(0, 100),
            maxProgress: 100,
            paused: true,
            indeterminate: current.totalBytes <= 0,
          ),
        );
      }
    }
  }

  void resumeDownload() {
    _downloader.resume();
    final current = progress.value;
    if (current != null) {
      progress.value = UpdateProgress(
        phase: UpdateDownloadPhase.downloading,
        receivedBytes: current.receivedBytes,
        totalBytes: current.totalBytes,
        speedBytesPerSecond: current.speedBytesPerSecond,
      );
    }
  }

  Future<ServiceResult<void>> retryDownload() async {
    final release = _pendingRelease ?? availableUpdate.value;
    if (release != null) {
      return guardVoid(() async {
        await _runDownload(release);
      });
    }

    return guardVoid(() async {
      await _downloader.retryLastDownload(
        onProgress: (value) {
          final current = _pendingRelease ?? availableUpdate.value;
          if (current != null) {
            _onDownloadProgress(current, value);
          } else {
            progress.value = value;
          }
        },
      );
      if (_downloadedApk != null) {
        progress.value = UpdateProgress(
          phase: UpdateDownloadPhase.readyToInstall,
          receivedBytes: await _downloadedApk!.length(),
          totalBytes: await _downloadedApk!.length(),
        );
        await _notifications.showUpdateReadyToInstall(
          version: _pendingRelease?.version ?? availableUpdate.value?.version ?? '',
        );
      }
    });
  }

  Future<ServiceResult<void>> installDownloadedApk() async {
    return guardVoid(() async {
      final file = await _resolveDownloadedApk();
      if (file == null || !await file.exists()) {
        throw const UpdateException(
          message: 'No downloaded APK found',
          code: 'UPDATE_APK_NOT_FOUND',
        );
      }

      progress.value = UpdateProgress(
        phase: UpdateDownloadPhase.installing,
        receivedBytes: await file.length(),
        totalBytes: await file.length(),
      );

      await _notifications.cancelUpdateDownload();

      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );
      if (result.type != ResultType.done) {
        throw UpdateException(
          message: result.message,
          code: 'UPDATE_INSTALL_FAILED',
        );
      }

      final release = _pendingRelease ?? availableUpdate.value;
      if (release != null) {
        await _repository.addHistory(
          UpdateHistoryEntry(
            version: release.version,
            installedAt: DateTime.now(),
            status: 'installer_launched',
          ),
        );
      }

      progress.value = const UpdateProgress(phase: UpdateDownloadPhase.idle);
    });
  }

  Future<File?> _resolveDownloadedApk() async {
    final cached = _downloadedApk;
    if (cached != null && await cached.exists()) return cached;

    final release = _pendingRelease ?? availableUpdate.value;
    final dir = await getApplicationSupportDirectory();
    final updatesDir = Directory(p.join(dir.path, 'updates'));

    if (release != null) {
      final named = File(p.join(updatesDir.path, release.apkFileName));
      if (await named.exists()) {
        _downloadedApk = named;
        return named;
      }
    }

    if (!await updatesDir.exists()) return null;
    final apks = updatesDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.apk'))
        .toList()
      ..sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
    if (apks.isEmpty) return null;
    _downloadedApk = apks.first;
    return apks.first;
  }

  Future<List<UpdateHistoryEntry>> getHistory() => _repository.getHistory();

  void clearPromptedUpdate() => availableUpdate.value = null;

  void _onNotificationTapped(String? payload) {
    if (payload == NotificationService.updateInstallPayload) {
      unawaited(installDownloadedApk());
      return;
    }
    if (payload == NotificationService.updateOpenPayload) {
      if (Get.currentRoute != AppRoutes.update) {
        unawaited(Get.toNamed<void>(AppRoutes.update));
      }
    }
  }
}
