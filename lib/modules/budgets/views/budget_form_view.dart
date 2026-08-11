import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/enums/app_enums.dart';
import '../controllers/budget_form_controller.dart';

class BudgetFormView extends GetView<BudgetFormController> {
  const BudgetFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return AppScaffold(
      title: controller.isEditing ? 'budgets_edit'.tr : 'budgets_add'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => AppDropdown<int>(
                items: controller.categories.map((c) => c.id).toList(),
                itemLabel: (id) =>
                    controller.categories.firstWhere((c) => c.id == id).name,
                value: controller.selectedCategoryId.value,
                label: 'budgets_category'.tr,
                onChanged: (v) => controller.selectedCategoryId.value = v,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.targetController,
              label: 'budgets_target'.tr,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.savings_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.thresholdController,
              label: 'budgets_warning_threshold'.tr,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.notifications_active_outlined,
            ),
            const SizedBox(height: 16),
            Obx(
              () => AppDropdown<BudgetPeriodType>(
                items: BudgetPeriodType.values,
                itemLabel: (type) => switch (type) {
                  BudgetPeriodType.monthly => 'budgets_period_monthly'.tr,
                  BudgetPeriodType.days7 => 'budgets_period_days7'.tr,
                  BudgetPeriodType.days15 => 'budgets_period_days15'.tr,
                  BudgetPeriodType.custom => 'budgets_period_custom'.tr,
                },
                value: controller.periodType.value,
                label: 'budgets_period_label'.tr,
                onChanged: (value) {
                  if (value != null) controller.setPeriodType(value);
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('budgets_period_start'.tr),
                subtitle: Text(dateFmt.format(controller.periodStart.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: controller.pickStartDate,
              ),
            ),
            Obx(() {
              if (controller.periodType.value != BudgetPeriodType.custom) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('budgets_period_end'.tr),
                  subtitle: Text(dateFmt.format(controller.periodEnd.value)),
                );
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('budgets_period_end'.tr),
                subtitle: Text(dateFmt.format(controller.periodEnd.value)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: controller.pickEndDate,
              );
            }),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('budgets_auto_repeat'.tr),
                subtitle: Text('budgets_auto_repeat_subtitle'.tr),
                value: controller.autoRepeat.value,
                onChanged: (value) => controller.autoRepeat.value = value,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(label: 'common_save'.tr, onPressed: controller.save),
          ],
        ),
      ),
    );
  }
}
