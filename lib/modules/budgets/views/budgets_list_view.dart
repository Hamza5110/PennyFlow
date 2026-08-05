import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/budgets_list_controller.dart';
import '../widgets/budget_list_tile.dart';

class BudgetsListView extends GetView<BudgetsListController> {
  const BudgetsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'budgets_title'.tr,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Obx(
              () => Text(
                'budgets_month_label'.trParams({
                  'month': controller.selectedMonth.value.toString(),
                  'year': controller.selectedYear.value.toString(),
                }),
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return AppLoadingIndicator(message: 'common_loading'.tr);
              }
              if (controller.items.isEmpty) {
                return AppEmptyState(
                  title: 'budgets_empty_title'.tr,
                  message: 'budgets_empty_message'.tr,
                  icon: Icons.pie_chart_outline_rounded,
                  actionLabel: 'budgets_add'.tr,
                  onAction: controller.openAdd,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadBudgets,
                child: ListView.separated(
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return BudgetListTile(
                      item: item,
                      currencyCode: currency,
                      onTap: () => controller.openEdit(item),
                      onDelete: () => controller.deleteBudget(item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.openAdd,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
