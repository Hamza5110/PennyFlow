import '../../core/extensions/date_extensions.dart';
import '../../core/constants/recurring_constants.dart';

/// Computes next run dates for recurring templates (FR-126).
abstract final class RecurringScheduleUtils {
  static const int maxCatchUpPerRun = 366;

  static DateTime initialNextRun(DateTime startDate) => startDate.startOfDay;

  static DateTime advance(DateTime current, String frequency) {
    switch (frequency) {
      case RecurringFrequencies.daily:
        return current.add(const Duration(days: 1)).startOfDay;
      case RecurringFrequencies.weekly:
        return current.add(const Duration(days: 7)).startOfDay;
      case RecurringFrequencies.monthly:
        return _addMonths(current, 1).startOfDay;
      case RecurringFrequencies.yearly:
        return DateTime(current.year + 1, current.month, current.day).startOfDay;
      default:
        return current.add(const Duration(days: 1)).startOfDay;
    }
  }

  static bool isDue(DateTime? nextRunDate, {DateTime? now}) {
    if (nextRunDate == null) return false;
    final reference = (now ?? DateTime.now()).endOfDay;
    return !nextRunDate.isAfter(reference);
  }

  static DateTime _addMonths(DateTime date, int months) {
    final totalMonths = date.month + months;
    final year = date.year + ((totalMonths - 1) ~/ 12);
    final month = ((totalMonths - 1) % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day);
  }
}
