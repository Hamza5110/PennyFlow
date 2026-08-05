import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/budget_progress_section.dart';
import '../widgets/dashboard_period_selector.dart';
import '../widgets/dashboard_summary_cards.dart';
import '../widgets/friend_summary_section.dart';
import '../widgets/monthly_spending_chart.dart';
import '../widgets/recent_transactions_section.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.summary.value == null) {
        return AppLoadingIndicator(message: 'common_loading'.tr);
      }

      final summary = controller.summary.value;
      if (summary == null) {
        return AppErrorView(
          message: 'common_something_went_wrong'.tr,
          onRetry: controller.loadDashboard,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.loadDashboard,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dashboard_title'.tr,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => DashboardPeriodSelector(
                        selected: controller.period.value,
                        onChanged: controller.changePeriod,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DashboardSummaryCards(
                      summary: summary,
                      currencyCode: controller.currencyCode,
                    ),
                    const SizedBox(height: 16),
                    FriendSummarySection(
                      summary: summary,
                      currencyCode: controller.currencyCode,
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => MonthlySpendingChart(
                        points: controller.monthlySpending.toList(),
                        currencyCode: controller.currencyCode,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => BudgetProgressSection(
                        budgets: controller.budgets.toList(),
                        currencyCode: controller.currencyCode,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => RecentTransactionsSection(
                        transactions: controller.recentTransactions.toList(),
                        currencyCode: controller.currencyCode,
                        onTransactionTap: controller.onTransactionTap,
                      ),
                    ),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
