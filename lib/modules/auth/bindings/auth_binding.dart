import 'package:get/get.dart';

import '../../../services/auth/auth_service.dart';
import '../../../services/backup/backup_service.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        Get.find<AuthService>(),
        Get.find<BackupService>(),
      ),
    );
  }
}
