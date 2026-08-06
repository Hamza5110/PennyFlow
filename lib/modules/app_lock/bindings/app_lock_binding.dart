import 'package:get/get.dart';

import '../../../data/repositories/profile_repository.dart';
import '../../../services/security/app_lock_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/startup/startup_service.dart';
import '../../../services/storage/secure_storage_service.dart';
import '../controllers/app_lock_controller.dart';

class AppLockBinding extends Bindings {
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

    Get.lazyPut<AppLockController>(
      () => AppLockController(
        Get.find<StartupService>(),
        Get.find<AppLockService>(),
        Get.find<SettingsService>(),
      ),
    );
  }
}
