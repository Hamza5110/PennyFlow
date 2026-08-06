import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/backup_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../data/models/backup/backup_manifest.dart';
import '../../data/models/enums/app_enums.dart';
import '../auth/auth_service.dart';
import '../reminder/reminder_service.dart';
import '../settings/settings_service.dart';
import 'backup_bundle_builder.dart';
import 'backup_bundle_restorer.dart';
import 'backup_snapshot_codec.dart';
import 'google_drive_backup_client.dart';

/// Orchestrates manual/automatic Google Drive backup and restore (FR-141–FR-148).
class BackupService extends GetxService with BaseService {
  BackupService(
    this._auth,
    this._settings,
    this._reminders,
    this._drive,
    this._builder,
    this._restorer,
    this._codec,
  );

  final AuthService _auth;
  final SettingsService _settings;
  final ReminderService _reminders;
  final GoogleDriveBackupClient _drive;
  final BackupBundleBuilder _builder;
  final BackupBundleRestorer _restorer;
  final BackupSnapshotCodec _codec;

  final Rxn<BackupProgress> progress = Rxn<BackupProgress>();
  final RxBool isRunning = false.obs;

  final _uuid = const Uuid();

  Future<ServiceResult<BackupRemoteMeta>> backupNow({bool manual = true}) async {
    if (isRunning.value) {
      return ServiceResult.failure(
        userMessage: 'A backup is already in progress',
        errorCode: 'BACKUP_IN_PROGRESS',
      );
    }

    if (!_auth.isSignedIn) {
      return ServiceResult.failure(
        userMessage: 'Sign in with Google to back up your data',
        errorCode: 'BACKUP_NOT_SIGNED_IN',
      );
    }

    final profileId = _settings.activeProfileId;
    if (profileId == null) {
      return ServiceResult.failure(
        userMessage: 'No active profile found',
        errorCode: 'PROFILE_NOT_FOUND',
      );
    }

    isRunning.value = true;
    File? bundleFile;
    try {
      await _settings.recordBackupMeta(
        at: DateTime.now(),
        sizeBytes: _settings.lastBackupSizeBytes.value ?? 0,
        status: BackupStatus.exporting,
      );
      _setProgress(BackupPhase.exporting, 0.1);

      final built = await _builder.build(
        profileId: profileId,
        googleAccountEmail: _auth.currentUser.value?.email,
        onProgress: (value) => _setProgress(BackupPhase.exporting, value),
      );
      bundleFile = built.bundle;

      _setProgress(BackupPhase.uploading, 0.1);
      await _settings.recordBackupMeta(
        at: DateTime.now(),
        sizeBytes: await bundleFile.length(),
        status: BackupStatus.uploading,
      );

      final remote = await _drive.uploadBackup(
        bundleFile: bundleFile,
        profileId: profileId,
      );

      _setProgress(BackupPhase.verifying, 0.5);
      await _settings.recordBackupMeta(
        at: DateTime.now(),
        sizeBytes: remote.sizeBytes,
        status: BackupStatus.verifying,
      );

      final downloaded = File(
        p.join(
          (await getTemporaryDirectory()).path,
          'pennyflow_verify_${_uuid.v4()}.zip',
        ),
      );
      try {
        await _drive.downloadBackup(meta: remote, targetFile: downloaded);
        await _restorer.validate(downloaded);
      } finally {
        if (await downloaded.exists()) {
          await downloaded.delete();
        }
      }

      await _settings.recordBackupMeta(
        at: remote.modifiedAt.toLocal(),
        sizeBytes: remote.sizeBytes,
        status: BackupStatus.success,
      );
      _setProgress(BackupPhase.idle, 1);
      log.i('Backup completed (${remote.sizeBytes} bytes)');
      return ServiceResult.success(remote);
    } catch (error, stackTrace) {
      await _settings.recordBackupMeta(
        at: DateTime.now(),
        sizeBytes: bundleFile != null ? await bundleFile.length() : 0,
        status: BackupStatus.failed,
      );
      _setProgress(BackupPhase.idle, 0);
      log.e('Backup failed', error: error, stackTrace: stackTrace);
      return ServiceResult.failure(
        userMessage: error is AppException
            ? error.message
            : 'Backup failed. Please try again.',
        errorCode: error is AppException ? error.code : 'BACKUP_ERROR',
        exception: error is AppException
            ? error
            : BackupException(message: error.toString(), cause: error),
      );
    } finally {
      if (bundleFile != null && await bundleFile.exists()) {
        await bundleFile.delete();
      }
      isRunning.value = false;
    }
  }

  Future<ServiceResult<void>> restoreLatest({required bool overwrite}) async {
    if (isRunning.value) {
      return ServiceResult.failure(
        userMessage: 'A restore is already in progress',
        errorCode: 'RESTORE_IN_PROGRESS',
      );
    }

    if (!_auth.isSignedIn) {
      return ServiceResult.failure(
        userMessage: 'Sign in with Google to restore your data',
        errorCode: 'BACKUP_NOT_SIGNED_IN',
      );
    }

    final profileId = _settings.activeProfileId;
    if (profileId == null) {
      return ServiceResult.failure(
        userMessage: 'No active profile found',
        errorCode: 'PROFILE_NOT_FOUND',
      );
    }

    isRunning.value = true;
    File? downloaded;
    File? safetySnapshot;
    try {
      final remote = await _drive.fetchRemoteMeta(profileId);
      if (remote == null) {
        return ServiceResult.failure(
          userMessage: 'No backup found in Google Drive',
          errorCode: 'BACKUP_NOT_FOUND',
        );
      }

      if (!overwrite && await _codec.profileHasData(profileId)) {
        return ServiceResult.failure(
          userMessage: 'Local data exists — confirm overwrite to restore',
          errorCode: 'RESTORE_NEEDS_CONFIRMATION',
        );
      }

      if (overwrite && await _codec.profileHasData(profileId)) {
        final built = await _builder.build(profileId: profileId);
        safetySnapshot = built.bundle;
      }

      _setProgress(BackupPhase.downloading, 0.1);
      downloaded = File(
        p.join(
          (await getTemporaryDirectory()).path,
          'pennyflow_restore_${_uuid.v4()}.zip',
        ),
      );
      await _drive.downloadBackup(meta: remote, targetFile: downloaded);

      _setProgress(BackupPhase.verifying, 0.35);
      await _restorer.validate(downloaded);

      _setProgress(BackupPhase.restoring, 0.55);
      await _restorer.restore(
        bundleFile: downloaded,
        targetProfileId: profileId,
        overwrite: overwrite,
        onProgress: (value) => _setProgress(BackupPhase.restoring, value),
      );

      await _reminders.rescheduleAll();
      _setProgress(BackupPhase.idle, 1);
      log.i('Restore completed for profile $profileId');
      return ServiceResult.success();
    } catch (error, stackTrace) {
      if (safetySnapshot != null) {
        await _attemptSafetyRollback(profileId, safetySnapshot);
      }
      _setProgress(BackupPhase.idle, 0);
      log.e('Restore failed', error: error, stackTrace: stackTrace);
      return ServiceResult.failure(
        userMessage: error is AppException
            ? error.message
            : 'Restore failed. Your local data was not changed.',
        errorCode: error is AppException ? error.code : 'RESTORE_ERROR',
        exception: error is AppException
            ? error
            : BackupException(message: error.toString(), cause: error),
      );
    } finally {
      if (downloaded != null && await downloaded.exists()) {
        await downloaded.delete();
      }
      if (safetySnapshot != null && await safetySnapshot.exists()) {
        await safetySnapshot.delete();
      }
      isRunning.value = false;
    }
  }

  Future<BackupRemoteMeta?> fetchRemoteMeta() async {
    final profileId = _settings.activeProfileId;
    if (profileId == null || !_auth.isSignedIn) return null;
    return _drive.fetchRemoteMeta(profileId);
  }

  Future<bool> shouldOfferRestore() async {
    if (!_auth.isSignedIn) return false;
    final profileId = _settings.activeProfileId;
    if (profileId == null) return false;
    if (await _codec.profileHasData(profileId)) return false;
    final remote = await _drive.fetchRemoteMeta(profileId);
    return remote != null;
  }

  Future<void> maybeRunAutoBackup() async {
    if (!_settings.autoBackupEnabled.value || !_auth.isSignedIn) return;
    if (isRunning.value) return;

    final lastAt = _settings.lastBackupAt.value;
    final due = lastAt == null ||
        DateTime.now().difference(lastAt) >= BackupConstants.autoBackupInterval;
    if (!due) return;

    final result = await backupNow(manual: false);
    if (result.isFailure) {
      log.w('Auto-backup failed: ${result.userMessage}');
    }
  }

  Future<void> _attemptSafetyRollback(int profileId, File snapshot) async {
    try {
      await _restorer.restore(
        bundleFile: snapshot,
        targetProfileId: profileId,
        overwrite: true,
      );
      log.w('Restored safety snapshot after failed restore');
    } catch (error, stackTrace) {
      log.e(
        'Safety snapshot rollback failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _setProgress(BackupPhase phase, double percent) {
    progress.value = BackupProgress(phase: phase, percent: percent);
  }
}
