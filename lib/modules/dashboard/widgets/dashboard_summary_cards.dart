import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/dashboard/dashboard_summary.dart';

class DashboardSummaryCards extends StatelessWidget {
  const DashboardSummaryCards({
    super.key,
    required this.summary,
    required this.currencyCode,
  });

  final DashboardSummary summary;
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
            label: 'dashboard_total_expense'.tr,
            value: _money(summary.totalExpense),
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
          ),
          _SummaryCardData(
            label: 'dashboard_total_income'.tr,
            value: _money(summary.totalIncome),
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
          ),
          _SummaryCardData(
            label: 'dashboard_balance'.tr,
            value: _money(summary.balance),
            color: theme.colorScheme.primary,
            icon: Icons.account_balance_wallet_outlined,
          ),
          _SummaryCardData(
            label: 'dashboard_today_spending'.tr,
            value: _money(summary.todaySpending),
            color: AppColors.expense,
            icon: Icons.today_outlined,
          ),
          _SummaryCardData(
            label: 'dashboard_month_spending'.tr,
            value: _money(summary.monthSpending),
            color: AppColors.pending,
            icon: Icons.calendar_month_outlined,
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
          itemBuilder: (context, index) => _SummaryCard(data: items[index]),
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
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SummaryCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          ],
        ),
      ),
    );
  }
}
