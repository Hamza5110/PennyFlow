import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/data/models/category.dart';
import 'package:spend_vault/data/models/expense.dart';
import 'package:spend_vault/data/models/income.dart';
import 'package:spend_vault/data/models/statistics/statistics_period.dart';
import 'package:spend_vault/data/repositories/category_repository.dart';
import 'package:spend_vault/data/repositories/expense_repository.dart';
import 'package:spend_vault/data/repositories/income_repository.dart';
import 'package:spend_vault/data/repositories/statistics_repository.dart';

import '../support/isar_test_helper.dart';

void main() {
  late TestIsarHarness harness;
  late StatisticsRepository repository;
  late CategoryRepository categories;

  setUp(() async {
    harness = await TestIsarHarness.open();
    final expenses = ExpenseRepository(harness.db);
    final incomes = IncomeRepository(harness.db);
    categories = CategoryRepository(harness.db);
    repository = StatisticsRepository(expenses, incomes, categories);
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('StatisticsRepository', () {
    test('loadBundle aggregates income, expense, and category breakdown', () async {
      final food = Category()
        ..name = 'Food'
        ..colorHex = '#F97316'
        ..iconKey = 'restaurant'
        ..profileId = 1;
      final foodId = await categories.put(food);

      await ExpenseRepository(harness.db).put(
        Expense()
          ..profileId = 1
          ..amount = 120
          ..categoryId = foodId
          ..accountId = 1
          ..date = DateTime(2026, 3, 10),
      );
      await ExpenseRepository(harness.db).put(
        Expense()
          ..profileId = 1
          ..amount = 80
          ..categoryId = foodId
          ..accountId = 1
          ..date = DateTime(2026, 3, 12),
      );
      await IncomeRepository(harness.db).put(
        Income()
          ..profileId = 1
          ..amount = 500
          ..accountId = 1
          ..source = 'Salary'
          ..date = DateTime(2026, 3, 5),
      );

      final bundle = await repository.loadBundle(
        1,
        StatisticsPeriod.thisMonth,
        now: DateTime(2026, 3, 15),
      );

      expect(bundle.summary.totalExpense, 200);
      expect(bundle.summary.totalIncome, 500);
      expect(bundle.summary.savings, 300);
      expect(bundle.incomeVsExpense, hasLength(2));
      expect(bundle.categories, hasLength(1));
      expect(bundle.categories.first.name, 'Food');
      expect(bundle.categories.first.amount, 200);
      expect(bundle.dailyPoints, isNotEmpty);
      expect(bundle.trendPoints, equals(bundle.dailyPoints));
    });
  });
}
