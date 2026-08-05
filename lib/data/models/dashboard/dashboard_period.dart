import '../../../core/utils/app_date_utils.dart';

/// Dashboard summary period selector (FR-009).
enum DashboardPeriod {
  today,
  thisWeek,
  thisMonth,
}

extension DashboardPeriodX on DashboardPeriod {
  DateRange toDateRange({DateTime? now}) {
    switch (this) {
      case DashboardPeriod.today:
        return AppDateUtils.rangeFor(DatePeriod.today, now: now);
      case DashboardPeriod.thisWeek:
        return AppDateUtils.rangeFor(DatePeriod.thisWeek, now: now);
      case DashboardPeriod.thisMonth:
        return AppDateUtils.rangeFor(DatePeriod.thisMonth, now: now);
    }
  }

  String get labelKey {
    switch (this) {
      case DashboardPeriod.today:
        return 'dashboard_period_today';
      case DashboardPeriod.thisWeek:
        return 'dashboard_period_week';
      case DashboardPeriod.thisMonth:
        return 'dashboard_period_month';
    }
  }
}
