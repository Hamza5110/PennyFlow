import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../data/models/statistics/category_statistic.dart';
import '../../data/models/statistics/statistics_chart_point.dart';
import '../../data/models/statistics/statistics_period.dart';
import '../../data/models/statistics/statistics_summary.dart';
import '../../data/repositories/statistics_repository.dart';
import '../settings/settings_service.dart';

class StatisticsService extends GetxService with BaseService {
  StatisticsService(this._repository, this._settings);

  final StatisticsRepository _repository;
  final SettingsService _settings;

  Future<StatisticsSummary> getSummary(StatisticsPeriod period) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return _emptySummary;
    return _repository.getSummary(profileId, period);
  }

  Future<List<StatisticsChartPoint>> getDailyExpenses(
    StatisticsPeriod period,
  ) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];
    return _repository.getDailyExpenses(profileId, period);
  }

  Future<List<StatisticsChartPoint>> getWeeklyExpenses(
    StatisticsPeriod period,
  ) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];
    return _repository.getWeeklyExpenses(profileId, period);
  }

  Future<List<StatisticsChartPoint>> getMonthlyExpenses({int months = 6}) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];
    return _repository.getMonthlyExpenses(profileId, months: months);
  }

  Future<List<StatisticsChartPoint>> getIncomeVsExpense(
    StatisticsPeriod period,
  ) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];
    return _repository.getIncomeVsExpense(profileId, period);
  }

  Future<List<StatisticsChartPoint>> getSpendingTrend(
    StatisticsPeriod period,
  ) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];
    return _repository.getSpendingTrend(profileId, period);
  }

  Future<List<CategoryStatistic>> getCategoryBreakdown(
    StatisticsPeriod period,
  ) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];
    return _repository.getCategoryBreakdown(profileId, period);
  }

  static const _emptySummary = StatisticsSummary(
    totalIncome: 0,
    totalExpense: 0,
    savings: 0,
    averageDailySpending: 0,
  );
}
