import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/base/base_service.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../backup/backup_bundle_builder.dart';
import '../backup/backup_bundle_restorer.dart';
import '../reminder/reminder_service.dart';
import 'settings_service.dart';

/// Local export/import independent of Google Drive (FR-187).
class DataTransferService extends GetxService with BaseService {
  DataTransferService(
    this._settings,
    this._builder,
    this._restorer,
    this._reminders,
  );

  final SettingsService _settings;
  final BackupBundleBuilder _builder;
  final BackupBundleRestorer _restorer;
  final ReminderService _reminders;
  final _uuid = const Uuid();

  Future<ServiceResult<File>> exportData() async {
    return guard(() async {
      final profileId = _settings.activeProfileId;
      if (profileId == null) {
        throw const NotFoundException(
          message: 'No active profile found',
          code: 'PROFILE_NOT_FOUND',
        );
      }

      final built = await _builder.build(profileId: profileId);
      final exportDir = await getApplicationDocumentsDirectory();
      final target = File(
        p.join(
          exportDir.path,
          'pennyflow_export_${profileId}_${_uuid.v4()}.zip',
        ),
      );
      await built.bundle.copy(target.path);
      if (await built.bundle.exists()) {
        await built.bundle.delete();
      }
      return target;
    });
  }

  Future<ServiceResult<void>> shareExport(File file) async {
    return guardVoid(() async {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'PennyFlow data export',
      );
    });
  }

  Future<ServiceResult<void>> importData({required bool overwrite}) async {
    return guardVoid(() async {
      final profileId = _settings.activeProfileId;
      if (profileId == null) {
        throw const NotFoundException(
          message: 'No active profile found',
          code: 'PROFILE_NOT_FOUND',
        );
      }

      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['zip'],
        withData: false,
      );
      if (picked == null || picked.files.isEmpty) return;

      final path = picked.files.single.path;
      if (path == null) {
        throw const BackupException(
          message: 'Could not read the selected file',
          code: 'IMPORT_FILE_UNREADABLE',
        );
      }

      await _restorer.validate(File(path));
      await _restorer.restore(
        bundleFile: File(path),
        targetProfileId: profileId,
        overwrite: overwrite,
      );
      await _reminders.rescheduleAll();
    });
  }
}
