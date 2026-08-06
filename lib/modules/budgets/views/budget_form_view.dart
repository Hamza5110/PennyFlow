import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
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
              () => AppDropdown<int>(
                items: List.generate(12, (i) => i + 1),
                itemLabel: (month) => _months[month - 1],
                value: controller.selectedMonth.value,
                label: 'budgets_month'.tr,
                onChanged: (v) {
                  if (v != null) controller.selectedMonth.value = v;
                },
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => AppDropdown<int>(
                items: [
                  DateTime.now().year - 1,
                  DateTime.now().year,
                  DateTime.now().year + 1,
                ],
                itemLabel: (year) => '$year',
                value: controller.selectedYear.value,
                label: 'budgets_year'.tr,
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
