import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/auth/google_sign_in_client.dart';
import '../../../services/backup/backup_bundle_builder.dart';
import '../../../services/backup/backup_bundle_restorer.dart';
import '../../../services/backup/backup_service.dart';
import '../../../services/backup/backup_snapshot_codec.dart';
import '../../../services/backup/google_drive_backup_client.dart';
import '../../../services/image/image_service.dart';
import '../../../services/reminder/reminder_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/storage/local_storage_service.dart';
import '../controllers/backup_controller.dart';

class BackupBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GoogleDriveBackupClient>()) {
      Get.put(
        GoogleDriveBackupClient(Get.find<GoogleSignInClient>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<BackupSnapshotCodec>()) {
      Get.put(
        BackupSnapshotCodec(Get.find<IsarDatabase>()),
        permanent: true,
      );
    }

    if (!Get.isRegistered<BackupBundleBuilder>()) {
      Get.put(
        BackupBundleBuilder(
          Get.find<BackupSnapshotCodec>(),
          Get.find<SettingsService>(),
          Get.find<LocalStorageService>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<BackupBundleRestorer>()) {
      Get.put(
        BackupBundleRestorer(
          Get.find<BackupSnapshotCodec>(),
          Get.find<SettingsService>(),
          Get.find<LocalStorageService>(),
          Get.find<ImageService>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<BackupService>()) {
      Get.put(
        BackupService(
          Get.find<AuthService>(),
          Get.find<SettingsService>(),
          Get.find<LocalStorageService>(),
          Get.find<ImageService>(),
          Get.find<ReminderService>(),
          Get.find<GoogleDriveBackupClient>(),
          Get.find<BackupBundleBuilder>(),
          Get.find<BackupBundleRestorer>(),
          Get.find<BackupSnapshotCodec>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<BackupController>(
      () => BackupController(
        Get.find<BackupService>(),
        Get.find<AuthService>(),
        Get.find<SettingsService>(),
      ),
    );
  }
}
