import 'package:get/get.dart';

import '../../../services/startup/startup_service.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(Get.find<StartupService>()),
    );
  }
}
