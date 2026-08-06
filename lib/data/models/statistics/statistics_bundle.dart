import 'category_statistic.dart';
import 'statistics_chart_point.dart';
import 'statistics_summary.dart';

/// Pre-aggregated statistics payload loaded in a single DB pass (Phase 20).
class StatisticsBundle {
  const StatisticsBundle({
    required this.summary,
    required this.dailyPoints,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.incomeVsExpense,
    required this.trendPoints,
    required this.categories,
  });

  final StatisticsSummary summary;
  final List<StatisticsChartPoint> dailyPoints;
  final List<StatisticsChartPoint> weeklyPoints;
  final List<StatisticsChartPoint> monthlyPoints;
  final List<StatisticsChartPoint> incomeVsExpense;
  final List<StatisticsChartPoint> trendPoints;
  final List<CategoryStatistic> categories;

  static const empty = StatisticsBundle(
    summary: StatisticsSummary(
      totalIncome: 0,
      totalExpense: 0,
      savings: 0,
      averageDailySpending: 0,
    ),
    dailyPoints: [],
    weeklyPoints: [],
    monthlyPoints: [],
    incomeVsExpense: [],
    trendPoints: [],
    categories: [],
  );
}
