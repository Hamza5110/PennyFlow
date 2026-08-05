import '../../../core/base/base_controller.dart';
import '../../../services/startup/startup_service.dart';

/// App lock gate shell — PIN/biometric verification arrives in Phase 19.
class AppLockController extends BaseController {
  AppLockController(this._startup);

  final StartupService _startup;

  Future<void> unlock() async {
    await runGuarded(() async {
      await _startup.navigateAfterUnlock();
    });
  }
}
