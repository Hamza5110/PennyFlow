import 'package:intl/intl.dart';

/// DateTime helpers used across filters, dashboards, and reports.
extension DateTimeExtensions on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth {
    final nextMonth = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(milliseconds: 1));
  }

  DateTime get startOfWeek {
    // Monday-based week (ISO-8601).
    final weekdayOffset = weekday - DateTime.monday;
    return startOfDay.subtract(Duration(days: weekdayOffset));
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isBetween(DateTime start, DateTime end) =>
      !isBefore(start) && !isAfter(end);

  String format([String pattern = 'dd MMM yyyy']) =>
      DateFormat(pattern).format(this);

  String get toIsoDate => DateFormat('yyyy-MM-dd').format(this);

  /// Milliseconds since epoch for Isar-friendly indexing helpers.
  int get epochMs => millisecondsSinceEpoch;
}

extension NullableDateTimeExtensions on DateTime? {
  String formatOrDash([String pattern = 'dd MMM yyyy']) =>
      this?.format(pattern) ?? '—';
}
