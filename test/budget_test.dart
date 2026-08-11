import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/utils/budget_period_utils.dart';
import 'package:penny_flow/data/models/budget.dart';
import 'package:penny_flow/data/models/budget/budget_input.dart';
import 'package:penny_flow/data/models/budget/budget_list_item.dart';
import 'package:penny_flow/data/models/dashboard/budget_progress.dart';
import 'package:penny_flow/data/models/enums/app_enums.dart';

void main() {
  group('BudgetInput', () {
    test('equality compares fields', () {
      final start = DateTime(2026, 8, 1);
      final end = DateTime(2026, 8, 31, 23, 59, 59, 999);
      final a = BudgetInput(
        categoryId: 1,
        targetAmount: 5000,
        periodType: BudgetPeriodType.monthly,
        periodStart: start,
        periodEnd: end,
      );
      final b = BudgetInput(
        categoryId: 1,
        targetAmount: 5000,
        periodType: BudgetPeriodType.monthly,
        periodStart: start,
        periodEnd: end,
      );
      expect(a, b);
    });
  });

  group('BudgetPeriodUtils', () {
    test('7-day auto-repeat advances to current cycle', () {
      final window = BudgetPeriodUtils.currentWindow(
        type: BudgetPeriodType.days7,
        periodStart: DateTime(2026, 8, 1),
        periodEnd: DateTime(2026, 8, 7, 23, 59, 59, 999),
        autoRepeat: true,
        reference: DateTime(2026, 8, 12),
      );
      expect(window.start, DateTime(2026, 8, 8));
      expect(window.end.day, 14);
      expect(window.lengthInDays, 7);
    });

    test('fixed range stays on template dates', () {
      final window = BudgetPeriodUtils.currentWindow(
        type: BudgetPeriodType.days15,
        periodStart: DateTime(2026, 8, 1),
        periodEnd: DateTime(2026, 8, 15, 23, 59, 59, 999),
        autoRepeat: false,
        reference: DateTime(2026, 9, 1),
      );
      expect(window.start, DateTime(2026, 8, 1));
      expect(window.end.day, 15);
    });

    test('monthly auto-repeat uses calendar month of reference', () {
      final window = BudgetPeriodUtils.currentWindow(
        type: BudgetPeriodType.monthly,
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31, 23, 59, 59, 999),
        autoRepeat: true,
        reference: DateTime(2026, 3, 10),
      );
      expect(window.start, DateTime(2026, 3, 1));
      expect(window.end.month, 3);
      expect(window.end.day, 31);
    });
  });

  group('BudgetListItem', () {
    test('computes ratio and remaining', () {
      final budget = Budget()
        ..targetAmount = 1000
        ..categoryId = 1
        ..year = 2026
        ..month = 8
        ..periodType = BudgetPeriodType.monthly.name
        ..periodStart = DateTime(2026, 8, 1)
        ..periodEnd = DateTime(2026, 8, 31, 23, 59, 59, 999)
        ..autoRepeat = true
        ..profileId = 1;

      final item = BudgetListItem(
        budget: budget,
        categoryName: 'Food',
        categoryColorHex: '#F97316',
        spent: 800,
        window: BudgetPeriodUtils.windowFor(budget),
      );

      expect(item.ratio, 0.8);
      expect(item.remaining, 200);
    });
  });

  group('BudgetProgress', () {
    test('computes ratio for dashboard', () {
      const progress = BudgetProgress(
        budgetId: 1,
        categoryName: 'Food',
        colorHex: '#F97316',
        spent: 1200,
        target: 1000,
      );
      expect(progress.ratio, 1.2);
      expect(progress.remaining, 0);
    });
  });
}
