import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/core/constants/recurring_constants.dart';
import 'package:spend_vault/core/utils/recurring_schedule_utils.dart';

void main() {
  group('RecurringScheduleUtils', () {
    test('advance daily adds one day', () {
      final current = DateTime(2026, 3, 10);
      final next = RecurringScheduleUtils.advance(
        current,
        RecurringFrequencies.daily,
      );
      expect(next, DateTime(2026, 3, 11));
    });

    test('advance weekly adds seven days', () {
      final current = DateTime(2026, 3, 10);
      final next = RecurringScheduleUtils.advance(
        current,
        RecurringFrequencies.weekly,
      );
      expect(next, DateTime(2026, 3, 17));
    });

    test('advance monthly handles month-end', () {
      final current = DateTime(2026, 1, 31);
      final next = RecurringScheduleUtils.advance(
        current,
        RecurringFrequencies.monthly,
      );
      expect(next, DateTime(2026, 2, 28));
    });

    test('isDue when next run is today or earlier', () {
      final today = DateTime(2026, 3, 15, 12);
      expect(
        RecurringScheduleUtils.isDue(DateTime(2026, 3, 15), now: today),
        isTrue,
      );
      expect(
        RecurringScheduleUtils.isDue(DateTime(2026, 3, 16), now: today),
        isFalse,
      );
    });
  });
}
