import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/base/base_service.dart';
import '../profile/profile_service.dart';
import '../settings/settings_service.dart';
import 'startup_route_resolver.dart';

/// Decides the post-splash and post-resume navigation targets (SRS §23).
class StartupService extends GetxService with BaseService {
  StartupService(this._settings, this._profiles);

  final SettingsService _settings;
  final ProfileService _profiles;

  Future<String> resolveInitialRoute() async {
    final hasProfile = await _profiles.hasAnyProfile();
    return StartupRouteResolver.resolve(
      appLockEnabled: _settings.isAppLockEnabled,
      isSessionUnlocked: _settings.isSessionUnlocked.value,
      hasProfile: hasProfile,
      hasCompletedOnboarding: _settings.hasCompletedOnboarding,
    );
  }

  Future<String> resolveResumeRoute() async {
    if (_settings.isAppLockEnabled && !_settings.isSessionUnlocked.value) {
      return AppRoutes.appLock;
    }
    return Get.currentRoute.isEmpty ? AppRoutes.home : Get.currentRoute;
  }

  Future<void> navigateToInitialRoute() async {
    final route = await resolveInitialRoute();
    log.i('Startup → $route');
    await Get.offAllNamed(route);
  }

  Future<void> navigateAfterUnlock() async {
    _settings.unlockSession();
    final hasProfile = await _profiles.hasAnyProfile();
    final route = hasProfile ? AppRoutes.home : AppRoutes.profileSetup;
    await Get.offAllNamed(route);
  }
}
