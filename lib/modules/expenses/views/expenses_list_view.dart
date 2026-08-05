import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/expenses_list_controller.dart';
import '../widgets/expense_filter_sheet.dart';
import '../widgets/expense_list_tile.dart';

class ExpensesListView extends GetView<ExpensesListController> {
  const ExpensesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'expense_search_hint'.tr,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                    onChanged: controller.onSearchChanged,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded),
                  onPressed: () => ExpenseFilterSheet.show(
                    initial: controller.filter.value,
                    onApply: controller.applyFilter,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: controller.openTrash,
                  tooltip: 'expense_trash'.tr,
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.filter.value.hasActiveFilters) {
              return Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: controller.clearFilters,
                  child: Text('expense_clear_filters'.tr),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return AppLoadingIndicator(message: 'common_loading'.tr);
              }
              if (controller.items.isEmpty) {
                return AppEmptyState(
                  title: 'expenses_empty_title'.tr,
                  message: 'expenses_empty_message'.tr,
                  icon: Icons.receipt_long_outlined,
                  actionLabel: 'expense_add'.tr,
                  onAction: controller.openAdd,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadExpenses,
                child: ListView.builder(
                  itemCount: controller.items.length,
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return ExpenseListTile(
                      item: item,
                      currencyCode: currency,
                      onTap: () => controller.openDetail(item),
                      onDelete: () => controller.deleteExpense(item),
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
