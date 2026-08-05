import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/income_sources.dart';
import '../../../core/constants/recurring_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_button.dart';
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
                DropdownButtonFormField<int>(
                  value: controller.selectedCategoryId.value,
                  decoration:
                      InputDecoration(labelText: 'expense_category'.tr),
                  items: controller.categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => controller.selectedCategoryId.value = v,
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  value: controller.useCustomSource.value
                      ? IncomeSources.custom
                      : controller.selectedSourceKey.value,
                  decoration: InputDecoration(labelText: 'income_source'.tr),
                  items: controller.sourceOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option.key,
                          child: Text(option.label),
                        ),
                      )
                      .toList(),
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
              DropdownButtonFormField<int>(
                value: controller.selectedAccountId.value,
                decoration: InputDecoration(labelText: 'expense_account'.tr),
                items: controller.accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => controller.selectedAccountId.value = v,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: controller.frequency.value,
                decoration:
                    InputDecoration(labelText: 'recurring_frequency'.tr),
                items: [
                  for (final freq in RecurringFrequencies.all)
                    DropdownMenuItem(
                      value: freq,
                      child: Text('recurring_freq_$freq'.tr),
                    ),
                ],
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
