import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/utils/app_date_utils.dart';
import 'package:penny_flow/data/models/expense/expense_filter.dart';

void main() {
  group('ExpenseFilter', () {
    test('empty filter has no active filters', () {
      expect(ExpenseFilter.empty.hasActiveFilters, isFalse);
    });

    test('search query activates filter', () {
      const filter = ExpenseFilter(searchQuery: 'coffee');
      expect(filter.hasActiveFilters, isTrue);
    });

    test('copyWith clears category when requested', () {
      const filter = ExpenseFilter(categoryId: 3);
      final cleared = filter.copyWith(clearCategory: true);
      expect(cleared.categoryId, isNull);
      expect(cleared.hasActiveFilters, isFalse);
    });

    test('copyWith preserves search when updating category', () {
      const filter = ExpenseFilter(searchQuery: 'fuel', categoryId: 2);
      final updated = filter.copyWith(categoryId: 5);
      expect(updated.searchQuery, 'fuel');
      expect(updated.categoryId, 5);
    });

    test('date period is part of active filters', () {
      const filter = ExpenseFilter(datePeriod: DatePeriod.thisMonth);
      expect(filter.hasActiveFilters, isTrue);
    });
  });
}
