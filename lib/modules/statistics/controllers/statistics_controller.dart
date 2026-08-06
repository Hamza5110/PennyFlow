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

  final RxSet<int> _loadedTabs = <int>{0}.obs;

  String get currencyCode => Get.find<SettingsService>().currencyCode.value;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    await runGuarded(() async {
      _loadedTabs
        ..clear()
        ..add(0);
      final bundle = await _statistics.loadBundle(period.value);
      summary.value = bundle.summary;
      dailyPoints.assignAll(bundle.dailyPoints);
      weeklyPoints.assignAll(bundle.weeklyPoints);
      monthlyPoints.assignAll(bundle.monthlyPoints);
      incomeVsExpense.assignAll(bundle.incomeVsExpense);
      trendPoints.assignAll(bundle.trendPoints);
      categories.assignAll(bundle.categories);
      _loadedTabs
        ..add(1)
        ..add(2)
        ..add(3)
        ..add(4);
    }, showErrorSnackbar: false);
  }

  bool isTabLoaded(int index) => _loadedTabs.contains(index);

  Future<void> changePeriod(StatisticsPeriod value) async {
    period.value = value;
    await loadStatistics();
  }
}
