import 'package:get/get.dart';

import '../../../services/profile/profile_service.dart';
import '../../../services/startup/startup_service.dart';
import '../controllers/profile_setup_controller.dart';

class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileSetupController>(
      () => ProfileSetupController(
        Get.find<ProfileService>(),
        Get.find<StartupService>(),
      ),
    );
  }
}
