import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/recurring_constants.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/recurring_list_controller.dart';
import '../widgets/recurring_list_tile.dart';

class RecurringListView extends GetView<RecurringListController> {
  const RecurringListView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'recurring_title'.tr,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Obx(
              () => SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: RecurringTransactionTypes.expense,
                    label: Text('recurring_expenses_tab'.tr),
                  ),
                  ButtonSegment(
                    value: RecurringTransactionTypes.income,
                    label: Text('recurring_income_tab'.tr),
                  ),
                ],
                selected: {controller.filterType.value},
                onSelectionChanged: (values) =>
                    controller.changeFilter(values.first),
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
                  title: 'recurring_empty_title'.tr,
                  message: 'recurring_empty_message'.tr,
                  icon: Icons.autorenew_rounded,
                  actionLabel: 'recurring_add'.tr,
                  onAction: controller.openAdd,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadTemplates,
                child: ListView.separated(
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return RecurringListTile(
                      item: item,
                      currencyCode: currency,
                      onTap: () => controller.openEdit(item),
                      onToggleActive: () => controller.toggleActive(item),
                      onDelete: () => controller.deleteTemplate(item),
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
