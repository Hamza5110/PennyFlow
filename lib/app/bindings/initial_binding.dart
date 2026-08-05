import 'package:get/get.dart';

import '../../core/logging/app_logger.dart';
import '../../data/local/database/isar_database.dart';
import '../../services/auth/auth_service.dart';
import '../../services/lifecycle/app_lifecycle_service.dart';
import '../../services/profile/profile_service.dart';
import '../../services/settings/settings_service.dart';
import '../../services/storage/local_storage_service.dart';
import '../../services/storage/secure_storage_service.dart';

/// App-wide dependency registration.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    AppLogger.instance.d('InitialBinding.dependencies()');

    assert(Get.isRegistered<LocalStorageService>());
    assert(Get.isRegistered<SecureStorageService>());
    assert(Get.isRegistered<IsarDatabase>());
    assert(Get.isRegistered<SettingsService>());
    assert(Get.isRegistered<ProfileService>());
    assert(Get.isRegistered<AuthService>());
    assert(Get.isRegistered<AppLifecycleService>());
  }
}
