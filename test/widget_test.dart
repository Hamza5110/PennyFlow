import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:penny_flow/app/routes/app_routes.dart';
import 'package:penny_flow/core/constants/app_constants.dart';
import 'package:penny_flow/data/models/auth_user.dart';
import 'package:penny_flow/data/models/dashboard/dashboard_period.dart';
import 'package:penny_flow/data/repositories/mock_dashboard_repository.dart';
import 'package:penny_flow/services/startup/startup_route_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(Get.reset);

  test('AppConstants expose product identity', () {
    expect(AppConstants.appName, 'PennyFlow');
    expect(AppConstants.databaseSchemaVersion, greaterThan(0));
  });

  group('StartupRouteResolver', () {
    test('routes to profile setup when no profile exists', () {
      expect(
        StartupRouteResolver.resolve(
          appLockEnabled: false,
          isSessionUnlocked: true,
          hasProfile: false,
          hasCompletedOnboarding: false,
        ),
        AppRoutes.profileSetup,
      );
    });

    test('routes to home when profile exists and onboarding done', () {
      expect(
        StartupRouteResolver.resolve(
          appLockEnabled: false,
          isSessionUnlocked: true,
          hasProfile: true,
          hasCompletedOnboarding: true,
        ),
        AppRoutes.home,
      );
    });

    test('routes to app lock when enabled and session locked', () {
      expect(
        StartupRouteResolver.resolve(
          appLockEnabled: true,
          isSessionUnlocked: false,
          hasProfile: true,
          hasCompletedOnboarding: true,
        ),
        AppRoutes.appLock,
      );
    });
  });

  group('AuthUser', () {
    test('serializes and deserializes JSON', () {
      const user = AuthUser(
        id: 'google-id-1',
        email: 'user@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
      );

      final restored = AuthUser.fromJson(user.toJson());
      expect(restored, user);
    });
  });

  group('MockDashboardRepository', () {
    late MockDashboardRepository repository;
    final now = DateTime(2026, 8, 5, 12);

    setUp(() {
      repository = MockDashboardRepository(referenceNow: now);
    });

    test('returns summary for selected period', () {
      final summary = repository.getSummary(DashboardPeriod.thisMonth);
      expect(summary.totalExpense, greaterThan(0));
      expect(summary.totalIncome, greaterThan(0));
      expect(summary.todaySpending, greaterThan(0));
    });

    test('adds quick expense and updates recent list', () {
      repository.addQuickExpense(
        amount: 250,
        categoryId: 'food',
        accountId: 'cash',
      );
      final recent = repository.getRecentTransactions(limit: 20);
      expect(recent.first.amount, 250);
      expect(recent.first.categoryName, 'Food');
    });

    test('returns six monthly chart points by default', () {
      final points = repository.getMonthlySpending();
      expect(points.length, 6);
    });
  });
}
