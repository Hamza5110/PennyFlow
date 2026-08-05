import '../../app/routes/app_routes.dart';

/// Pure startup routing rules (SRS §23) — unit-testable without GetX.
abstract final class StartupRouteResolver {
  static String resolve({
    required bool appLockEnabled,
    required bool isSessionUnlocked,
    required bool hasProfile,
    required bool hasCompletedOnboarding,
  }) {
    if (appLockEnabled && !isSessionUnlocked) {
      return AppRoutes.appLock;
    }
    if (!hasProfile || !hasCompletedOnboarding) {
      return AppRoutes.profileSetup;
    }
    return AppRoutes.home;
  }
}
