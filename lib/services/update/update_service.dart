import 'dart:io';

import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/base/base_service.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/utils/version_utils.dart';
import '../../data/models/update/release_info.dart';
import '../../data/models/update/update_history_entry.dart';
import '../../data/models/update/update_progress.dart';
import '../../data/repositories/update_repository.dart';
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
  );

  final SettingsService _settings;
  final GitHubReleaseClient _github;
  final ApkDownloadManager _downloader;
  final UpdateRepository _repository;

  final Rxn<ReleaseInfo> availableUpdate = Rxn<ReleaseInfo>();
  final Rxn<UpdateProgress> progress = Rxn<UpdateProgress>();
  final RxString currentVersion = ''.obs;
  final RxString currentBuild = ''.obs;

  ReleaseInfo? _pendingRelease;
  File? _downloadedApk;

  Future<UpdateService> init() async {
    final info = await PackageInfo.fromPlatform();
    currentVersion.value = info.version;
    currentBuild.value = info.buildNumber;
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
        if (!manual) rethrow;
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

  Future<ServiceResult<void>> downloadAvailableUpdate() async {
    final release = _pendingRelease ?? availableUpdate.value;
    if (release == null) {
      return ServiceResult.failure(
        userMessage: 'No update available to download',
        errorCode: 'UPDATE_NOT_AVAILABLE',
      );
    }

    return guardVoid(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'updates', release.apkFileName));
      if (await file.parent.exists() == false) {
        await file.parent.create(recursive: true);
      }

      await _downloader.download(
        release: release,
        target: file,
        onProgress: (value) => progress.value = value,
      );

      progress.value = UpdateProgress(
        phase: UpdateDownloadPhase.readyToInstall,
        receivedBytes: await file.length(),
        totalBytes: await file.length(),
      );
      _downloadedApk = file;
    });
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
    return guardVoid(() async {
      await _downloader.retryLastDownload(
        onProgress: (value) => progress.value = value,
      );
      if (_downloadedApk != null) {
        progress.value = UpdateProgress(
          phase: UpdateDownloadPhase.readyToInstall,
          receivedBytes: await _downloadedApk!.length(),
          totalBytes: await _downloadedApk!.length(),
        );
      }
    });
  }

  Future<ServiceResult<void>> installDownloadedApk() async {
    return guardVoid(() async {
      final file = _downloadedApk;
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

  Future<List<UpdateHistoryEntry>> getHistory() => _repository.getHistory();

  void clearPromptedUpdate() => availableUpdate.value = null;
}
