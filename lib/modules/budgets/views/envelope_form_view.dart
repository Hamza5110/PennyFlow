import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/enums/app_enums.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/envelope_form_controller.dart';

class EnvelopeFormView extends GetView<EnvelopeFormController> {
  const EnvelopeFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: controller.isEditing ? 'envelope_edit'.tr : 'envelope_add'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.totalController,
              label: 'envelope_total'.tr,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.account_balance_wallet_outlined,
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
                  BudgetPeriodType.months3 => 'budgets_period_months3'.tr,
                  BudgetPeriodType.custom => 'budgets_period_custom'.tr,
                },
                value: controller.periodType.value,
                label: 'budgets_period_label'.tr,
                onChanged: (value) {
                  if (value != null) controller.setPeriodType(value);
                },
              ),
            ),
            Obx(() {
              if (controller.periodType.value != BudgetPeriodType.custom) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'budgets_period_custom_hint'.tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }),
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Text(
              'envelope_funding_section'.tr,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'envelope_funding_hint'.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Obx(
              () => Text(
                'envelope_allocated_of_total'.trParams({
                  'allocated': AppFormatters.currency(
                    controller.fundingAllocated.value,
                    currencyCode: currency,
                  ),
                  'total': AppFormatters.currency(
                    controller.totalAmount.value,
                    currencyCode: currency,
                  ),
                }),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            _FundingColumnHeaders(
              accountLabel: 'envelope_account'.tr,
              amountLabel: 'expense_amount'.tr,
            ),
            const SizedBox(height: 8),
            Obx(() {
              return Column(
                children: [
                  for (var i = 0; i < controller.fundingRows.length; i++)
                    _FundingSplitRow(
                      index: i,
                      controller: controller,
                    ),
                ],
              );
            }),
            TextButton.icon(
              onPressed: controller.addFundingRow,
              icon: const Icon(Icons.add),
              label: Text('envelope_add_funding'.tr),
            ),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('envelope_record_income'.tr),
                subtitle: Text('envelope_record_income_subtitle'.tr),
                value: controller.recordFundingAsIncome.value,
                onChanged: (value) =>
                    controller.recordFundingAsIncome.value = value,
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

class _FundingColumnHeaders extends StatelessWidget {
  const _FundingColumnHeaders({
    required this.accountLabel,
    required this.amountLabel,
  });

  final String accountLabel;
  final String amountLabel;

  static const double amountWidth = 112;
  static const double removeWidth = 40;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.7),
        );
    return Row(
      children: [
        Expanded(child: Text(accountLabel, style: style)),
        const SizedBox(width: 8),
        SizedBox(
          width: amountWidth,
          child: Text(amountLabel, style: style),
        ),
        const SizedBox(width: removeWidth),
      ],
    );
  }
}

class _FundingSplitRow extends StatelessWidget {
  const _FundingSplitRow({
    required this.index,
    required this.controller,
  });

  final int index;
  final EnvelopeFormController controller;

  @override
  Widget build(BuildContext context) {
    final row = controller.fundingRows[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppDropdown<int>(
                items: controller.accounts.map((a) => a.id).toList(),
                itemLabel: (id) =>
                    controller.accounts.firstWhere((a) => a.id == id).name,
                value: row.accountId,
                hint: 'envelope_account'.tr,
                onChanged: (v) => controller.setAccount(index, v),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: _FundingColumnHeaders.amountWidth,
              child: _AlignedAmountField(controller: row.amountController),
            ),
            SizedBox(
              width: _FundingColumnHeaders.removeWidth,
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => controller.removeFundingRow(index),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlignedAmountField extends StatelessWidget {
  const _AlignedAmountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final borderColor = colors.outline.withValues(alpha: 0.4);

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: '0',
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ??
            colors.surfaceContainerHighest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
