import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/budget_form_controller.dart';

class BudgetFormView extends GetView<BudgetFormController> {
  const BudgetFormView({super.key});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: controller.isEditing ? 'budgets_edit'.tr : 'budgets_add'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => DropdownButtonFormField<int>(
                initialValue: controller.selectedCategoryId.value,
                decoration: InputDecoration(labelText: 'budgets_category'.tr),
                items: controller.categories
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => controller.selectedCategoryId.value = v,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.targetController,
              label: 'budgets_target'.tr,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              () => DropdownButtonFormField<int>(
                initialValue: controller.selectedMonth.value,
                decoration: InputDecoration(labelText: 'budgets_month'.tr),
                items: [
                  for (var i = 0; i < 12; i++)
                    DropdownMenuItem(
                      value: i + 1,
                      child: Text(_months[i]),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) controller.selectedMonth.value = v;
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<int>(
                initialValue: controller.selectedYear.value,
                decoration: InputDecoration(labelText: 'budgets_year'.tr),
                items: [
                  for (final year in [
                    DateTime.now().year - 1,
                    DateTime.now().year,
                    DateTime.now().year + 1,
                  ])
                    DropdownMenuItem(value: year, child: Text('$year')),
                ],
                onChanged: (v) {
                  if (v != null) controller.selectedYear.value = v;
                },
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
