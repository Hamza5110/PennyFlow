import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/budget/budget_list_item.dart';

class BudgetListTile extends StatelessWidget {
  const BudgetListTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.periodLabel,
    required this.onTap,
    required this.onDelete,
  });

  final BudgetListItem item;
  final String currencyCode;
  final String periodLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = item.ratio;
    final statusColor = AppColors.budgetStatusColor(ratio);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor:
            _parseColor(item.categoryColorHex).withValues(alpha: 0.15),
        child: Icon(
          Icons.pie_chart_outline,
          color: _parseColor(item.categoryColorHex),
        ),
      ),
      title: Text(item.categoryName, style: theme.textTheme.titleMedium),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            periodLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio > 1 ? 1 : ratio.clamp(0, 1),
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'budgets_spent_remaining'.trParams({
              'spent': AppFormatters.currency(
                item.spent,
                currencyCode: currencyCode,
              ),
              'remaining': AppFormatters.currency(
                item.remaining,
                currencyCode: currencyCode,
              ),
              'target': AppFormatters.currency(
                item.target,
                currencyCode: currencyCode,
              ),
            }),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: onDelete,
      ),
    );
  }
}
