import '../../../core/utils/app_date_utils.dart';

/// Statistics period selector (FR-089–FR-092).
enum StatisticsPeriod {
  today,
  thisWeek,
  thisMonth,
  lastMonth,
}

extension StatisticsPeriodX on StatisticsPeriod {
  DateRange toDateRange({DateTime? now}) {
    switch (this) {
      case StatisticsPeriod.today:
        return AppDateUtils.rangeFor(DatePeriod.today, now: now);
      case StatisticsPeriod.thisWeek:
        return AppDateUtils.rangeFor(DatePeriod.thisWeek, now: now);
      case StatisticsPeriod.thisMonth:
        return AppDateUtils.rangeFor(DatePeriod.thisMonth, now: now);
      case StatisticsPeriod.lastMonth:
        return AppDateUtils.rangeFor(DatePeriod.lastMonth, now: now);
    }
  }

  String get labelKey {
    switch (this) {
      case StatisticsPeriod.today:
        return 'dashboard_period_today';
      case StatisticsPeriod.thisWeek:
        return 'dashboard_period_week';
      case StatisticsPeriod.thisMonth:
        return 'dashboard_period_month';
      case StatisticsPeriod.lastMonth:
        return 'search_last_month';
    }
  }
}
