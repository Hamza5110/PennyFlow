import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../controllers/statistics_controller.dart';
import '../widgets/statistics_bar_chart.dart';
import '../widgets/statistics_chart_card.dart';
import '../widgets/statistics_income_expense_chart.dart';
import '../widgets/statistics_line_chart.dart';
import '../widgets/statistics_period_selector.dart';
import '../widgets/statistics_pie_chart.dart';
import '../widgets/statistics_summary_cards.dart';

class StatisticsTabView extends GetView<StatisticsController> {
  const StatisticsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Obx(
                    () => StatisticsPeriodSelector(
                      selected: controller.period.value,
                      onChanged: controller.changePeriod,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorWeight: 2,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                  labelStyle: Theme.of(context).textTheme.titleMedium,
                  unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'statistics_tab_overview'.tr),
                    Tab(text: 'statistics_tab_daily'.tr),
                    Tab(text: 'statistics_tab_weekly'.tr),
                    Tab(text: 'statistics_tab_monthly'.tr),
                    Tab(text: 'statistics_tab_categories'.tr),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.summary.value == null) {
                return AppLoadingIndicator(message: 'common_loading'.tr);
              }

              if (controller.summary.value == null) {
                return AppErrorView(
                  message: 'common_something_went_wrong'.tr,
                  onRetry: controller.loadStatistics,
                );
              }

              return TabBarView(
                children: [
                  _OverviewTab(controller: controller),
                  _DailyTab(controller: controller),
                  _WeeklyTab(controller: controller),
                  _MonthlyTab(controller: controller),
                  _CategoriesTab(controller: controller),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () => StatisticsSummaryCards(
              summary: controller.summary.value!,
              currencyCode: controller.currencyCode,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => StatisticsChartCard(
              title: 'statistics_income_vs_expense'.tr,
              child: StatisticsIncomeExpenseChart(
                points: controller.incomeVsExpense.toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => StatisticsChartCard(
              title: 'statistics_spending_trend'.tr,
              child: StatisticsLineChart(
                points: controller.trendPoints.toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => StatisticsChartCard(
              title: 'statistics_top_categories'.tr,
              child: StatisticsPieChart(
                categories: controller.categories.toList(),
                currencyCode: controller.currencyCode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTab extends StatelessWidget {
  const _DailyTab({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () => StatisticsChartCard(
              title: 'statistics_daily_expenses'.tr,
              child: StatisticsBarChart(
                points: controller.dailyPoints.toList(),
                barColor: AppColors.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTab extends StatelessWidget {
  const _WeeklyTab({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () => StatisticsChartCard(
              title: 'statistics_weekly_expenses'.tr,
              child: StatisticsBarChart(
                points: controller.weeklyPoints.toList(),
                barColor: AppColors.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyTab extends StatelessWidget {
  const _MonthlyTab({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () => StatisticsChartCard(
              title: 'statistics_monthly_expenses'.tr,
              child: StatisticsBarChart(
                points: controller.monthlyPoints.toList(),
                barColor: AppColors.brandPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.controller});

  final StatisticsController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadStatistics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Obx(
            () => StatisticsChartCard(
              title: 'statistics_category_breakdown'.tr,
              child: StatisticsPieChart(
                categories: controller.categories.toList(),
                currencyCode: controller.currencyCode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
