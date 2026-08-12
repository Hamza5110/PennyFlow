import '../../data/models/budget.dart';
import '../../data/models/budget_envelope.dart';
import '../../data/models/enums/app_enums.dart';

/// Inclusive date window for budget spending (start 00:00 → end 23:59:59.999).
class BudgetPeriodWindow {
  const BudgetPeriodWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) =>
      !date.isBefore(start) && !date.isAfter(end);

  int get lengthInDays =>
      BudgetPeriodUtils.endOfDay(end)
          .difference(BudgetPeriodUtils.startOfDay(start))
          .inDays +
      1;
}

/// Resolves the active spend window for a budget, including auto-repeat cycles.
abstract final class BudgetPeriodUtils {
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  static DateTime endOfMonth(int year, int month) =>
      DateTime(year, month + 1).subtract(const Duration(milliseconds: 1));

  /// End of a span of [monthCount] calendar months starting at [start].
  static DateTime endAfterMonths(DateTime start, int monthCount) {
    final anchor = startOfDay(start);
    final lastMonthStart = DateTime(
      anchor.year,
      anchor.month + monthCount - 1,
    );
    return endOfMonth(lastMonthStart.year, lastMonthStart.month);
  }

  static BudgetPeriodType parseType(String raw) {
    return BudgetPeriodType.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => BudgetPeriodType.monthly,
    );
  }

  static BudgetPeriodType typeOf(Budget budget) => parseType(budget.periodType);

  static BudgetPeriodType typeOfEnvelope(BudgetEnvelope envelope) =>
      parseType(envelope.periodType);

  /// Template length in whole days for fixed-length / custom periods.
  static int templateLengthDays({
    required BudgetPeriodType type,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    switch (type) {
      case BudgetPeriodType.days7:
        return 7;
      case BudgetPeriodType.days15:
        return 15;
      case BudgetPeriodType.custom:
        final days =
            endOfDay(periodEnd).difference(startOfDay(periodStart)).inDays + 1;
        return days < 1 ? 1 : days;
      case BudgetPeriodType.monthly:
      case BudgetPeriodType.months3:
        return 0;
    }
  }

  /// Builds the first-period end date from a start + period type.
  static DateTime defaultPeriodEnd({
    required BudgetPeriodType type,
    required DateTime periodStart,
    DateTime? customEnd,
  }) {
    final start = startOfDay(periodStart);
    switch (type) {
      case BudgetPeriodType.monthly:
        return endOfMonth(start.year, start.month);
      case BudgetPeriodType.months3:
        return endAfterMonths(start, 3);
      case BudgetPeriodType.days7:
        return endOfDay(start.add(const Duration(days: 6)));
      case BudgetPeriodType.days15:
        return endOfDay(start.add(const Duration(days: 14)));
      case BudgetPeriodType.custom:
        final end = customEnd ?? start;
        return endOfDay(end.isBefore(start) ? start : end);
    }
  }

  static BudgetPeriodWindow windowFor(
    Budget budget, {
    DateTime? reference,
  }) {
    return currentWindow(
      type: typeOf(budget),
      periodStart: budget.periodStart,
      periodEnd: budget.periodEnd,
      autoRepeat: budget.autoRepeat,
      reference: reference,
    );
  }

  static BudgetPeriodWindow windowForEnvelope(
    BudgetEnvelope envelope, {
    DateTime? reference,
  }) {
    return currentWindow(
      type: typeOfEnvelope(envelope),
      periodStart: envelope.periodStart,
      periodEnd: envelope.periodEnd,
      autoRepeat: envelope.autoRepeat,
      reference: reference,
    );
  }

  static BudgetPeriodWindow currentWindow({
    required BudgetPeriodType type,
    required DateTime periodStart,
    required DateTime periodEnd,
    required bool autoRepeat,
    DateTime? reference,
  }) {
    final now = reference ?? DateTime.now();
    final start = startOfDay(periodStart);
    final end = endOfDay(periodEnd);

    if (!autoRepeat) {
      return BudgetPeriodWindow(start: start, end: end);
    }

    if (type == BudgetPeriodType.monthly) {
      final monthStart = DateTime(now.year, now.month);
      return BudgetPeriodWindow(
        start: monthStart,
        end: endOfMonth(now.year, now.month),
      );
    }

    if (type == BudgetPeriodType.months3) {
      return _months3Window(templateStart: start, reference: now);
    }

    final lengthDays = templateLengthDays(
      type: type,
      periodStart: start,
      periodEnd: end,
    );

    if (now.isBefore(start)) {
      return BudgetPeriodWindow(
        start: start,
        end: endOfDay(start.add(Duration(days: lengthDays - 1))),
      );
    }

    final elapsedDays = startOfDay(now).difference(start).inDays;
    final cycleIndex = elapsedDays ~/ lengthDays;
    final cycleStart = start.add(Duration(days: cycleIndex * lengthDays));
    final cycleEnd = endOfDay(
      cycleStart.add(Duration(days: lengthDays - 1)),
    );
    return BudgetPeriodWindow(start: cycleStart, end: cycleEnd);
  }

  /// 3-month cycles anchored to [templateStart]'s day-of-month when possible.
  static BudgetPeriodWindow _months3Window({
    required DateTime templateStart,
    required DateTime reference,
  }) {
    final now = startOfDay(reference);
    if (now.isBefore(templateStart)) {
      return BudgetPeriodWindow(
        start: templateStart,
        end: endAfterMonths(templateStart, 3),
      );
    }

    final monthsElapsed = (now.year - templateStart.year) * 12 +
        (now.month - templateStart.month);
    final cycleIndex = monthsElapsed ~/ 3;
    final cycleStartMonth =
        DateTime(templateStart.year, templateStart.month + cycleIndex * 3);
    final day = templateStart.day;
    final daysInMonth = DateTime(
      cycleStartMonth.year,
      cycleStartMonth.month + 1,
      0,
    ).day;
    final cycleStart = DateTime(
      cycleStartMonth.year,
      cycleStartMonth.month,
      day.clamp(1, daysInMonth),
    );
    return BudgetPeriodWindow(
      start: cycleStart,
      end: endAfterMonths(cycleStart, 3),
    );
  }

  /// Whether the budget should appear in the active list for [reference].
  static bool isActive(
    Budget budget, {
    DateTime? reference,
  }) {
    final now = reference ?? DateTime.now();
    if (budget.autoRepeat) return true;
    return windowFor(budget, reference: now).contains(now);
  }

  static bool isEnvelopeActive(
    BudgetEnvelope envelope, {
    DateTime? reference,
  }) {
    final now = reference ?? DateTime.now();
    if (envelope.autoRepeat) return true;
    return windowForEnvelope(envelope, reference: now).contains(now);
  }

  static bool rangesOverlap(
    DateTime aStart,
    DateTime aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) {
    return !aEnd.isBefore(bStart) && !bEnd.isBefore(aStart);
  }

  static String periodTypeLabel(BudgetPeriodType type) {
    return switch (type) {
      BudgetPeriodType.monthly => 'budgets_period_monthly',
      BudgetPeriodType.days7 => 'budgets_period_days7',
      BudgetPeriodType.days15 => 'budgets_period_days15',
      BudgetPeriodType.months3 => 'budgets_period_months3',
      BudgetPeriodType.custom => 'budgets_period_custom',
    };
  }
}
