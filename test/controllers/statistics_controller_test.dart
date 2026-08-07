import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:penny_flow/data/models/category.dart';
import 'package:penny_flow/data/models/expense.dart';
import 'package:penny_flow/data/models/statistics/statistics_period.dart';
import 'package:penny_flow/data/repositories/category_repository.dart';
import 'package:penny_flow/data/repositories/expense_repository.dart';
import 'package:penny_flow/data/repositories/income_repository.dart';
import 'package:penny_flow/data/repositories/statistics_repository.dart';
import 'package:penny_flow/modules/statistics/controllers/statistics_controller.dart';
import 'package:penny_flow/services/settings/settings_service.dart';
import 'package:penny_flow/services/statistics/statistics_service.dart';
import 'package:penny_flow/services/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestIsarHarness harness;
  late StatisticsController controller;
  late SettingsService settings;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    harness = await TestIsarHarness.open();

    final localStorage = LocalStorageService();
    await localStorage.init();
    settings = SettingsService(localStorage);
    await settings.init();
    await settings.setActiveProfileId(1);
    Get.put<SettingsService>(settings);

    final categories = CategoryRepository(harness.db);
    final categoryId = await categories.put(
      Category()
        ..name = 'Food'
        ..colorHex = '#F97316'
        ..iconKey = 'restaurant'
        ..profileId = 1,
    );

    await ExpenseRepository(harness.db).put(
      Expense()
        ..profileId = 1
        ..amount = 250
        ..categoryId = categoryId
        ..accountId = 1
        ..date = DateTime.now(),
    );

    final statistics = StatisticsService(
      StatisticsRepository(
        ExpenseRepository(harness.db),
        IncomeRepository(harness.db),
        categories,
      ),
      settings,
    );

    controller = StatisticsController(statistics);
    Get.put(controller);
  });

  tearDown(() async {
    Get.reset();
    await harness.dispose();
  });

  group('StatisticsController', () {
    test('loadStatistics populates summary from repository bundle', () async {
      await controller.loadStatistics();

      expect(controller.summary.value?.totalExpense, 250);
      expect(controller.dailyPoints, isNotEmpty);
      expect(controller.isTabLoaded(0), isTrue);
      expect(controller.isTabLoaded(4), isTrue);
    });

    test('changePeriod updates selected period', () async {
      await controller.changePeriod(StatisticsPeriod.lastMonth);
      expect(controller.period.value, StatisticsPeriod.lastMonth);
      expect(controller.summary.value, isNotNull);
    });
  });
}
