import '../extensions/date_extensions.dart';

/// Date-range helpers for filters (FR-105) and dashboard periods (FR-009).
enum DatePeriod {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  custom,
}

class DateRange {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime value) => value.isBetween(start, end);

  Duration get duration => end.difference(start);
}

abstract final class AppDateUtils {
  static DateRange rangeFor(DatePeriod period, {DateTime? now}) {
    final current = now ?? DateTime.now();
    switch (period) {
      case DatePeriod.today:
        return DateRange(start: current.startOfDay, end: current.endOfDay);
      case DatePeriod.yesterday:
        final yesterday = current.subtract(const Duration(days: 1));
        return DateRange(
          start: yesterday.startOfDay,
          end: yesterday.endOfDay,
        );
      case DatePeriod.thisWeek:
        return DateRange(
          start: current.startOfWeek,
          end: current.endOfDay,
        );
      case DatePeriod.thisMonth:
        return DateRange(
          start: current.startOfMonth,
          end: current.endOfDay,
        );
      case DatePeriod.lastMonth:
        final lastMonthDate = DateTime(current.year, current.month - 1, 1);
        return DateRange(
          start: lastMonthDate.startOfMonth,
          end: lastMonthDate.endOfMonth,
        );
      case DatePeriod.custom:
        throw ArgumentError(
          'Use DateRange directly for custom periods',
        );
    }
  }

  static int daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  static DateRange? resolveFilterRange({
    DatePeriod? period,
    DateRange? customRange,
  }) {
    if (customRange != null) return customRange;
    if (period == null || period == DatePeriod.custom) return null;
    return rangeFor(period);
  }
}
