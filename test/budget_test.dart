import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/data/models/budget.dart';
import 'package:penny_flow/data/models/budget/budget_input.dart';
import 'package:penny_flow/data/models/budget/budget_list_item.dart';
import 'package:penny_flow/data/models/dashboard/budget_progress.dart';

void main() {
  group('BudgetInput', () {
    test('equality compares fields', () {
      const a = BudgetInput(
        categoryId: 1,
        targetAmount: 5000,
        year: 2026,
        month: 8,
      );
      const b = BudgetInput(
        categoryId: 1,
        targetAmount: 5000,
        year: 2026,
        month: 8,
      );
      expect(a, b);
    });
  });

  group('BudgetListItem', () {
    test('computes ratio and remaining', () {
      final budget = Budget()
        ..targetAmount = 1000
        ..categoryId = 1
        ..year = 2026
        ..month = 8
        ..profileId = 1;

      final item = BudgetListItem(
        budget: budget,
        categoryName: 'Food',
        categoryColorHex: '#F97316',
        spent: 800,
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
