import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/date_filter_section.dart';
import '../../../data/models/report/report_scope.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () => AppScaffold(
        title: 'reports_title'.tr,
        isLoading: controller.isLoading.value,
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('reports_type_label'.tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<ReportType>(
              segments: [
                ButtonSegment(
                  value: ReportType.monthly,
                  label: Text('reports_type_monthly'.tr),
                ),
                ButtonSegment(
                  value: ReportType.yearly,
                  label: Text('reports_type_yearly'.tr),
                ),
                ButtonSegment(
                  value: ReportType.custom,
                  label: Text('reports_type_custom'.tr),
                ),
              ],
              selected: {controller.reportType.value},
              onSelectionChanged: (values) =>
                  controller.setReportType(values.first),
            ),
            const SizedBox(height: 16),
            if (controller.reportType.value == ReportType.monthly) ...[
              _MonthYearPicker(controller: controller),
            ] else if (controller.reportType.value == ReportType.yearly) ...[
              _YearPicker(controller: controller),
            ] else ...[
              DateFilterSection(
                initialPeriod: DatePeriod.custom,
                initialCustomRange: controller.customRange.value,
                label: 'reports_custom_range'.tr,
                onChanged: controller.setCustomRange,
              ),
            ],
            const SizedBox(height: 20),
            Text('reports_format_label'.tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<ReportFormat>(
              segments: [
                ButtonSegment(
                  value: ReportFormat.pdf,
                  label: Text('reports_format_pdf'.tr),
                ),
                ButtonSegment(
                  value: ReportFormat.excel,
                  label: Text('reports_format_excel'.tr),
                ),
                ButtonSegment(
                  value: ReportFormat.csv,
                  label: Text('reports_format_csv'.tr),
                ),
              ],
              selected: {controller.format.value},
              onSelectionChanged: (values) =>
                  controller.setFormat(values.first),
            ),
            const SizedBox(height: 20),
            Text('reports_sections_label'.tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('reports_section_income'.tr),
                    value: controller.includeIncome.value,
                    onChanged: (value) =>
                        controller.includeIncome.value = value,
                  ),
                  SwitchListTile(
                    title: Text('reports_section_expenses'.tr),
                    value: controller.includeExpenses.value,
                    onChanged: (value) =>
                        controller.includeExpenses.value = value,
                  ),
                  SwitchListTile(
                    title: Text('reports_section_friends'.tr),
                    value: controller.includeFriends.value,
                    onChanged: (value) =>
                        controller.includeFriends.value = value,
                  ),
                  SwitchListTile(
                    title: Text('reports_section_categories'.tr),
                    value: controller.includeCategorySummary.value,
                    onChanged: (value) =>
                        controller.includeCategorySummary.value = value,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'reports_generate'.tr,
              icon: Icons.download_rounded,
              isLoading: controller.isLoading.value,
              onPressed: controller.generateReport,
            ),
            if (controller.lastGenerated.value != null) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'reports_share'.tr,
                icon: Icons.share_rounded,
                variant: AppButtonVariant.outlined,
                onPressed: controller.shareLastReport,
              ),
              const SizedBox(height: 8),
              Text(
                'reports_saved_hint'.trParams({
                  'file': controller.lastGenerated.value!.fileName,
                }),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthYearPicker extends StatelessWidget {
  const _MonthYearPicker({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(6, (index) => now.year - index);

    return Row(
      children: [
        Expanded(
          child: AppDropdown<int>(
            items: List.generate(12, (index) => index + 1),
            itemLabel: (month) => month.toString(),
            value: controller.selectedMonth.value,
            label: 'budgets_month'.tr,
            onChanged: (value) {
              if (value != null) controller.setMonth(value);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppDropdown<int>(
            items: years,
            itemLabel: (year) => year.toString(),
            value: controller.selectedYear.value,
            label: 'budgets_year'.tr,
            onChanged: (value) {
              if (value != null) controller.setYear(value);
            },
          ),
        ),
      ],
    );
  }
}

class _YearPicker extends StatelessWidget {
  const _YearPicker({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(6, (index) => now.year - index);

    return AppDropdown<int>(
      items: years,
      itemLabel: (year) => year.toString(),
      value: controller.selectedYear.value,
      label: 'budgets_year'.tr,
      onChanged: (value) {
        if (value != null) controller.setYear(value);
      },
    );
  }
}
