import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/dashboard/budget_progress.dart';

class BudgetProgressSection extends StatelessWidget {
  const BudgetProgressSection({
    super.key,
    required this.budgets,
    required this.currencyCode,
  });

  final List<BudgetProgress> budgets;
  final String currencyCode;

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (budgets.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'dashboard_budgets'.tr,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed<void>(AppRoutes.budgets),
                  child: Text('budgets_manage'.tr),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final budget in budgets) ...[
              _BudgetRow(
                budget: budget,
                currencyCode: currencyCode,
                accent: _parseColor(budget.colorHex),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({
    required this.budget,
    required this.currencyCode,
    required this.accent,
  });

  final BudgetProgress budget;
  final String currencyCode;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = budget.ratio.clamp(0.0, 1.2);
    final statusColor = AppColors.budgetStatusColor(budget.ratio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                budget.categoryName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              AppFormatters.percent(budget.ratio, decimals: 0),
              style: theme.textTheme.labelMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio > 1 ? 1 : ratio,
            minHeight: 8,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: statusColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'dashboard_budget_spent'.trParams({
            'spent': AppFormatters.currency(
              budget.spent,
              currencyCode: currencyCode,
            ),
            'target': AppFormatters.currency(
              budget.target,
              currencyCode: currencyCode,
            ),
          }),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
