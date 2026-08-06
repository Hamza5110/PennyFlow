import 'package:get/get.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../services/backup/backup_bundle_builder.dart';
import '../../../services/backup/backup_bundle_restorer.dart';
import '../../../services/profile/profile_service.dart';
import '../../../services/reminder/reminder_service.dart';
import '../../../services/security/app_lock_service.dart';
import '../../../services/settings/data_transfer_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/storage/secure_storage_service.dart';
import '../../../services/update/update_service.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppLockService>()) {
      Get.put(
        AppLockService(
          Get.find<SettingsService>(),
          Get.find<SecureStorageService>(),
          Get.find<ProfileRepository>(),
        ),
        permanent: true,
      );
    }

    if (!Get.isRegistered<DataTransferService>()) {
      Get.put(
        DataTransferService(
          Get.find<SettingsService>(),
          Get.find<BackupBundleBuilder>(),
          Get.find<BackupBundleRestorer>(),
          Get.find<ReminderService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<SettingsController>(
      () => SettingsController(
        Get.find<SettingsService>(),
        Get.find<ProfileService>(),
        Get.find<DataTransferService>(),
        Get.find<UpdateService>(),
        Get.find<AppLockService>(),
      ),
    );
  }
}
