import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/statistics/statistics_summary.dart';

class StatisticsSummaryCards extends StatelessWidget {
  const StatisticsSummaryCards({
    super.key,
    required this.summary,
    required this.currencyCode,
  });

  final StatisticsSummary summary;
  final String currencyCode;

  String _money(double value) => AppFormatters.currency(
        value,
        currencyCode: currencyCode,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final baseAspectRatio = crossAxisCount == 3 ? 1.55 : 1.35;
        final childAspectRatio = baseAspectRatio / textScale.clamp(1.0, 2.0);
        final items = [
          _SummaryCardData(
            label: 'statistics_total_income'.tr,
            value: _money(summary.totalIncome),
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
          ),
          _SummaryCardData(
            label: 'statistics_total_expense'.tr,
            value: _money(summary.totalExpense),
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
          ),
          _SummaryCardData(
            label: 'statistics_savings'.tr,
            value: _money(summary.savings),
            color: summary.savings >= 0
                ? AppColors.income
                : AppColors.expense,
            icon: Icons.savings_outlined,
          ),
          _SummaryCardData(
            label: 'statistics_avg_daily'.tr,
            value: _money(summary.averageDailySpending),
            color: AppColors.pending,
            icon: Icons.trending_up_rounded,
          ),
          if (summary.largestExpenseAmount != null)
            _SummaryCardData(
              label: 'statistics_largest_expense'.tr,
              value: _money(summary.largestExpenseAmount!),
              subtitle: summary.largestExpenseLabel,
              color: AppColors.expense,
              icon: Icons.receipt_long_outlined,
            ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => _SummaryCard(
            data: items[index],
            theme: theme,
          ),
        );
      },
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final String? subtitle;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.theme});

  final _SummaryCardData data;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(data.icon, size: 18, color: data.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: data.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (data.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                data.subtitle!,
                style: theme.textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
