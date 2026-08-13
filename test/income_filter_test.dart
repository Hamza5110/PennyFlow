import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/core/constants/income_sources.dart';
import 'package:spend_vault/core/utils/app_date_utils.dart';
import 'package:spend_vault/data/models/income/income_filter.dart';

void main() {
  group('IncomeFilter', () {
    test('empty filter has no active filters', () {
      expect(IncomeFilter.empty.hasActiveFilters, isFalse);
    });

    test('source filter activates filter state', () {
      const filter = IncomeFilter(source: IncomeSources.salary);
      expect(filter.hasActiveFilters, isTrue);
    });

    test('copyWith clears source when requested', () {
      const filter = IncomeFilter(source: IncomeSources.bonus);
      final cleared = filter.copyWith(clearSource: true);
      expect(cleared.source, isNull);
    });

    test('date period is part of active filters', () {
      const filter = IncomeFilter(datePeriod: DatePeriod.thisMonth);
      expect(filter.hasActiveFilters, isTrue);
    });
  });

  group('IncomeSources', () {
    test('predefined keys are recognized', () {
      expect(IncomeSources.isPredefinedKey(IncomeSources.salary), isTrue);
      expect(IncomeSources.isPredefinedKey('Side Hustle'), isFalse);
    });
  });
}
