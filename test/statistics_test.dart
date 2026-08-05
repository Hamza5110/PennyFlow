import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/extensions/date_extensions.dart';
import 'package:penny_flow/data/models/statistics/statistics_period.dart';

void main() {
  final reference = DateTime(2026, 3, 15, 14, 30);

  group('StatisticsPeriod', () {
    test('today maps to current day range', () {
      final range = StatisticsPeriod.today.toDateRange(now: reference);
      expect(range.start, DateTime(2026, 3, 15, 0, 0));
      expect(range.end, DateTime(2026, 3, 15, 23, 59, 59, 999));
    });

    test('thisWeek starts at week start', () {
      final range = StatisticsPeriod.thisWeek.toDateRange(now: reference);
      expect(range.start, reference.startOfWeek);
      expect(range.end, reference.endOfDay);
    });

    test('thisMonth starts at month start', () {
      final range = StatisticsPeriod.thisMonth.toDateRange(now: reference);
      expect(range.start, DateTime(2026, 3, 1, 0, 0));
      expect(range.end, reference.endOfDay);
    });

    test('lastMonth covers previous calendar month', () {
      final range = StatisticsPeriod.lastMonth.toDateRange(now: reference);
      expect(range.start, DateTime(2026, 2, 1, 0, 0));
      expect(range.end, DateTime(2026, 2, 28, 23, 59, 59, 999));
    });

    test('labelKey resolves for each period', () {
      for (final period in StatisticsPeriod.values) {
        expect(period.labelKey, isNotEmpty);
      }
    });
  });
}
