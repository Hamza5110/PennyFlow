import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/backup/backup_manifest.dart';
import '../../../data/models/enums/app_enums.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/backup/backup_service.dart';
import '../../../services/settings/settings_service.dart';

class BackupController extends BaseController {
  BackupController(this._backup, this._auth, this._settings);

  final BackupService _backup;
  final AuthService _auth;
  final SettingsService _settings;

  final Rxn<BackupRemoteMeta> remoteMeta = Rxn<BackupRemoteMeta>();
  final RxBool isDeletingRemote = false.obs;

  bool get isSignedIn => _auth.isSignedIn;

  RxBool get autoBackupEnabled => _settings.autoBackupEnabled;
  Rxn<DateTime> get lastBackupAt => _settings.lastBackupAt;
  RxnInt get lastBackupSizeBytes => _settings.lastBackupSizeBytes;
  Rx<BackupStatus> get lastBackupStatus => _settings.lastBackupStatus;
  Rxn<BackupProgress> get progress => _backup.progress;
  RxBool get isRunning => _backup.isRunning;

  @override
  void onInit() {
    super.onInit();
    loadRemoteMeta();
  }

  Future<void> loadRemoteMeta() async {
    remoteMeta.value = await _backup.fetchRemoteMeta();
  }

  String formatSize(int? bytes) =>
      bytes == null ? '—' : AppFormatters.fileSize(bytes);

  String statusLabel(BackupStatus status) {
    switch (status) {
      case BackupStatus.idle:
        return 'backup_status_idle'.tr;
      case BackupStatus.exporting:
        return 'backup_status_exporting'.tr;
      case BackupStatus.uploading:
        return 'backup_status_uploading'.tr;
      case BackupStatus.verifying:
        return 'backup_status_verifying'.tr;
      case BackupStatus.success:
        return 'backup_status_success'.tr;
      case BackupStatus.failed:
        return 'backup_status_failed'.tr;
    }
  }

  Future<void> setAutoBackup(bool enabled) async {
    if (!isSignedIn && enabled) {
      ErrorHandler.showError('backup_sign_in_required'.tr);
      return;
    }
    await _settings.setAutoBackupEnabled(enabled);
  }

  Future<void> backupNow() async {
    if (!isSignedIn) {
      ErrorHandler.showError('backup_sign_in_required'.tr);
      return;
    }

    await runGuarded(() async {
      final result = await _backup.backupNow();
      if (result.success) {
        ErrorHandler.showSuccess('backup_success'.tr);
        await loadRemoteMeta();
        return;
      }
      if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    }, trackLoading: false);
  }

  Future<void> restore() async {
    if (!isSignedIn) {
      ErrorHandler.showError('backup_sign_in_required'.tr);
      return;
    }

    await runGuarded(() async {
      final result = await _backup.restoreLatest(overwrite: false);
      if (result.success) {
        ErrorHandler.showSuccess('backup_restore_success'.tr);
        return;
      }
      if (result.errorCode == 'RESTORE_NEEDS_CONFIRMATION') {
        final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: Text('backup_restore_confirm_title'.tr),
            content: Text('backup_restore_confirm_message'.tr),
            actions: [
              TextButton(
                onPressed: () => Get.back<bool>(result: false),
                child: Text('common_cancel'.tr),
              ),
              TextButton(
                onPressed: () => Get.back<bool>(result: true),
                child: Text('backup_restore_confirm_action'.tr),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          final overwriteResult =
              await _backup.restoreLatest(overwrite: true);
          if (overwriteResult.success) {
            ErrorHandler.showSuccess('backup_restore_success'.tr);
          } else if (overwriteResult.userMessage != null) {
            ErrorHandler.showError(overwriteResult.userMessage!);
          }
        }
        return;
      }
      if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    }, trackLoading: false);
  }

  Future<void> deleteRemoteBackup() async {
    if (!isSignedIn) {
      ErrorHandler.showError('backup_sign_in_required'.tr);
      return;
    }

    if (remoteMeta.value == null) {
      ErrorHandler.showError('backup_not_found'.tr);
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('backup_delete_confirm_title'.tr),
        content: Text('backup_delete_confirm_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: true),
            child: Text('common_delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isDeletingRemote.value = true;
    try {
      final result = await _backup.deleteRemoteBackup();
      if (result.success) {
        remoteMeta.value = null;
        ErrorHandler.showSuccess('backup_delete_success'.tr);
        return;
      }
      if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    } finally {
      isDeletingRemote.value = false;
    }
  }

  void openSignIn() => Get.toNamed<void>(AppRoutes.auth);
}
