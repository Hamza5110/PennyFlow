import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/income_sources.dart';
import '../../../core/constants/recurring_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/recurring_form_controller.dart';

class RecurringFormView extends GetView<RecurringFormController> {
  const RecurringFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffold(
        title: controller.isEditing ? 'recurring_edit'.tr : 'recurring_add'.tr,
        isLoading: controller.isLoading.value,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: RecurringTransactionTypes.expense,
                    label: Text('recurring_type_expense'.tr),
                  ),
                  ButtonSegment(
                    value: RecurringTransactionTypes.income,
                    label: Text('recurring_type_income'.tr),
                  ),
                ],
                selected: {controller.transactionType.value},
                onSelectionChanged: controller.isEditing
                    ? null
                    : (values) => controller.transactionType.value =
                        values.first,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: controller.amountController,
                label: 'recurring_amount'.tr,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_outlined,
              ),
              const SizedBox(height: 16),
              if (controller.transactionType.value ==
                  RecurringTransactionTypes.expense) ...[
                AppDropdown<int>(
                  items: controller.categories.map((c) => c.id).toList(),
                  itemLabel: (id) => controller.categories
                      .firstWhere((c) => c.id == id)
                      .name,
                  value: controller.selectedCategoryId.value,
                  label: 'expense_category'.tr,
                  onChanged: (v) => controller.selectedCategoryId.value = v,
                ),
              ] else ...[
                AppDropdown<String>(
                  items: controller.sourceOptions.map((o) => o.key).toList(),
                  itemLabel: (key) => controller.sourceOptions
                      .firstWhere((o) => o.key == key)
                      .label,
                  value: controller.useCustomSource.value
                      ? IncomeSources.custom
                      : controller.selectedSourceKey.value,
                  label: 'income_source'.tr,
                  onChanged: controller.onSourceChanged,
                ),
                if (controller.useCustomSource.value) ...[
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: controller.customSourceController,
                    label: 'income_custom_source'.tr,
                  ),
                ],
              ],
              const SizedBox(height: 16),
              AppDropdown<int>(
                items: controller.accounts.map((a) => a.id).toList(),
                itemLabel: (id) =>
                    controller.accounts.firstWhere((a) => a.id == id).name,
                value: controller.selectedAccountId.value,
                label: 'expense_account'.tr,
                onChanged: (v) => controller.selectedAccountId.value = v,
              ),
              const SizedBox(height: 16),
              AppDropdown<String>(
                items: RecurringFrequencies.all,
                itemLabel: (freq) => 'recurring_freq_$freq'.tr,
                value: controller.frequency.value,
                label: 'recurring_frequency'.tr,
                onChanged: (v) {
                  if (v != null) controller.frequency.value = v;
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => controller.pickStartDate(context),
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  'recurring_start_date'.trParams({
                    'date': controller.startDate.value.format('dd MMM yyyy'),
                  }),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: controller.notesController,
                label: 'expense_notes'.tr,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('recurring_active'.tr),
                value: controller.isActive.value,
                onChanged: (value) => controller.isActive.value = value,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'common_save'.tr,
                isLoading: controller.isLoading.value,
                onPressed: controller.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
