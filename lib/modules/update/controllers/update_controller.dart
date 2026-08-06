import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/update/release_info.dart';
import '../../../data/models/update/update_history_entry.dart';
import '../../../data/models/update/update_progress.dart';
import '../../../services/update/update_service.dart';

class UpdateController extends BaseController {
  UpdateController(this._update);

  final UpdateService _update;

  Rxn<ReleaseInfo> get release => _update.availableUpdate;
  Rxn<UpdateProgress> get progress => _update.progress;
  RxString get currentVersion => _update.currentVersion;
  RxString get currentBuild => _update.currentBuild;

  final RxList<UpdateHistoryEntry> history = <UpdateHistoryEntry>[].obs;

  bool get isDownloading {
    final phase = progress.value?.phase;
    return phase == UpdateDownloadPhase.downloading ||
        phase == UpdateDownloadPhase.paused;
  }

  bool get isReadyToInstall =>
      progress.value?.phase == UpdateDownloadPhase.readyToInstall;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    history.value = await _update.getHistory();
  }

  Future<void> checkForUpdate() async {
    await runGuarded(() async {
      final result = await _update.checkForUpdate(manual: true);
      if (!result.success) {
        if (result.userMessage != null) {
          ErrorHandler.showError(result.userMessage!);
        }
        return;
      }
      if (result.data == null) {
        ErrorHandler.showSuccess('update_up_to_date'.tr);
      }
    });
  }

  Future<void> download() async {
    await runGuarded(() async {
      final result = await _update.downloadAvailableUpdate();
      if (!result.success && result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    }, trackLoading: false);
  }

  void pauseDownload() => _update.pauseDownload();

  void resumeDownload() => _update.resumeDownload();

  Future<void> retryDownload() async {
    await runGuarded(() async {
      final result = await _update.retryDownload();
      if (!result.success && result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    }, trackLoading: false);
  }

  Future<void> install() async {
    await runGuarded(() async {
      final result = await _update.installDownloadedApk();
      if (result.success) {
        ErrorHandler.showSuccess('update_install_launched'.tr);
        await loadHistory();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  String formatSize(int bytes) => AppFormatters.fileSize(bytes);

  String formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond <= 0) return '—';
    return '${AppFormatters.fileSize(bytesPerSecond.round())}/s';
  }

  String phaseLabel(UpdateDownloadPhase phase) {
    switch (phase) {
      case UpdateDownloadPhase.idle:
        return 'update_phase_idle'.tr;
      case UpdateDownloadPhase.checking:
        return 'update_phase_checking'.tr;
      case UpdateDownloadPhase.downloading:
        return 'update_phase_downloading'.tr;
      case UpdateDownloadPhase.paused:
        return 'update_phase_paused'.tr;
      case UpdateDownloadPhase.verifying:
        return 'update_phase_verifying'.tr;
      case UpdateDownloadPhase.readyToInstall:
        return 'update_phase_ready'.tr;
      case UpdateDownloadPhase.installing:
        return 'update_phase_installing'.tr;
      case UpdateDownloadPhase.failed:
        return 'update_phase_failed'.tr;
    }
  }

  String historyStatusLabel(String status) {
    switch (status) {
      case 'installer_launched':
        return 'update_history_installer_launched'.tr;
      case 'installed':
        return 'update_history_installed'.tr;
      default:
        return status;
    }
  }
}
