import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/budgets_list_controller.dart';
import '../widgets/budget_list_tile.dart';
import '../widgets/envelope_list_tile.dart';

class BudgetsListView extends GetView<BudgetsListController> {
  const BudgetsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'budgets_title'.tr,
      actions: [
        IconButton(
          tooltip: 'envelope_add'.tr,
          onPressed: controller.openAddEnvelope,
          icon: const Icon(Icons.account_balance_wallet_outlined),
        ),
        IconButton(
          tooltip: 'budgets_add'.tr,
          onPressed: controller.openAdd,
          icon: const Icon(Icons.pie_chart_outline),
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.items.isEmpty &&
            controller.envelopes.isEmpty) {
          return AppLoadingIndicator(message: 'common_loading'.tr);
        }

        final isEmpty =
            controller.items.isEmpty && controller.envelopes.isEmpty;
        if (isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppEmptyState(
                    title: 'budgets_empty_title'.tr,
                    message: 'budgets_empty_message'.tr,
                    icon: Icons.pie_chart_outline_rounded,
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'envelope_add'.tr,
                    onPressed: controller.openAddEnvelope,
                    expand: false,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'budgets_add'.tr,
                    onPressed: controller.openAdd,
                    expand: false,
                    variant: AppButtonVariant.outlined,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadBudgets,
          child: ListView(
            children: [
              _SectionHeader(
                title: 'envelope_section_label'.tr,
                actionLabel: 'envelope_add'.tr,
                onAdd: controller.openAddEnvelope,
              ),
              if (controller.envelopes.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'envelope_section_empty'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                )
              else
                for (final item in controller.envelopes)
                  EnvelopeListTile(
                    item: item,
                    currencyCode: currency,
                    periodLabel: controller.envelopePeriodLabel(item),
                    onTap: () => controller.openEditEnvelope(item),
                    onDelete: () => controller.deleteEnvelope(item),
                  ),
              _SectionHeader(
                title: 'budgets_active_label'.tr,
                actionLabel: 'budgets_add'.tr,
                onAdd: controller.openAdd,
              ),
              if (controller.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    'budgets_category_empty'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                )
              else
                for (final item in controller.items)
                  BudgetListTile(
                    item: item,
                    currencyCode: currency,
                    periodLabel: controller.periodLabel(item),
                    onTap: () => controller.openEdit(item),
                    onDelete: () => controller.deleteBudget(item),
                  ),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAdd,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: theme.textTheme.titleSmall),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
