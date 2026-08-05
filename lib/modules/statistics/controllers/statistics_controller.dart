import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../data/models/statistics/category_statistic.dart';
import '../../../data/models/statistics/statistics_chart_point.dart';
import '../../../data/models/statistics/statistics_period.dart';
import '../../../data/models/statistics/statistics_summary.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/statistics/statistics_service.dart';

class StatisticsController extends BaseController {
  StatisticsController(this._statistics);

  final StatisticsService _statistics;

  final Rx<StatisticsPeriod> period = StatisticsPeriod.thisMonth.obs;
  final Rxn<StatisticsSummary> summary = Rxn<StatisticsSummary>();
  final RxList<StatisticsChartPoint> dailyPoints = <StatisticsChartPoint>[].obs;
  final RxList<StatisticsChartPoint> weeklyPoints =
      <StatisticsChartPoint>[].obs;
  final RxList<StatisticsChartPoint> monthlyPoints =
      <StatisticsChartPoint>[].obs;
  final RxList<StatisticsChartPoint> incomeVsExpense =
      <StatisticsChartPoint>[].obs;
  final RxList<StatisticsChartPoint> trendPoints = <StatisticsChartPoint>[].obs;
  final RxList<CategoryStatistic> categories = <CategoryStatistic>[].obs;

  String get currencyCode => Get.find<SettingsService>().currencyCode.value;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    await runGuarded(() async {
      final selected = period.value;
      summary.value = await _statistics.getSummary(selected);
      dailyPoints.assignAll(await _statistics.getDailyExpenses(selected));
      weeklyPoints.assignAll(await _statistics.getWeeklyExpenses(selected));
      monthlyPoints.assignAll(await _statistics.getMonthlyExpenses());
      incomeVsExpense.assignAll(await _statistics.getIncomeVsExpense(selected));
      trendPoints.assignAll(await _statistics.getSpendingTrend(selected));
      categories.assignAll(await _statistics.getCategoryBreakdown(selected));
    }, showErrorSnackbar: false);
  }

  Future<void> changePeriod(StatisticsPeriod value) async {
    period.value = value;
    await loadStatistics();
  }
}
