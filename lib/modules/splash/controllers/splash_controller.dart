import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/logging/app_logger.dart';
import '../../../services/startup/startup_service.dart';

/// Bootstrap gate — loads startup state and routes to the next screen.
class SplashController extends BaseController {
  SplashController(this._startup);

  final StartupService _startup;

  final RxString statusMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    statusMessage.value = 'splash_starting'.tr;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await runGuarded(() async {
      final started = DateTime.now();
      statusMessage.value = 'splash_preparing'.tr;

      AppLogger.instance.i('Splash bootstrap complete — resolving route');

      final elapsed = DateTime.now().difference(started);
      final remaining = AppConstants.splashMinDuration - elapsed;
      if (remaining > Duration.zero) {
        await Future<void>.delayed(remaining);
      }

      statusMessage.value = 'splash_ready'.tr;
      await _startup.navigateToInitialRoute();
    }, showErrorSnackbar: true);
  }
}
