import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/budget_envelope/budget_envelope_list_item.dart';
import '../../../services/budget_envelope/budget_envelope_service.dart';

class EnvelopeListTile extends StatelessWidget {
  const EnvelopeListTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.periodLabel,
    required this.onTap,
    required this.onDelete,
  });

  final BudgetEnvelopeListItem item;
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
    final accent = _parseColor(BudgetEnvelopeService.envelopeColorHex);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: accent.withValues(alpha: 0.15),
        child: Icon(Icons.wallet_outlined, color: accent),
      ),
      title: Text('envelope_list_title'.tr, style: theme.textTheme.titleMedium),
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
          if (item.fundingProgress.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'envelope_funding_section'.tr,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            for (final fund in item.fundingProgress) ...[
              _MiniProgressRow(
                label: fund.accountName,
                spent: fund.spent,
                target: fund.funded,
                currencyCode: currencyCode,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline_rounded),
        onPressed: onDelete,
      ),
    );
  }
}

class _MiniProgressRow extends StatelessWidget {
  const _MiniProgressRow({
    required this.label,
    required this.spent,
    required this.target,
    required this.currencyCode,
  });

  final String label;
  final double spent;
  final double target;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = target <= 0 ? 0.0 : spent / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            Text(
              '${AppFormatters.currency(spent, currencyCode: currencyCode)} / '
              '${AppFormatters.currency(target, currencyCode: currencyCode)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio > 1 ? 1 : ratio.clamp(0, 1),
            minHeight: 4,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: AppColors.budgetStatusColor(ratio),
          ),
        ),
      ],
    );
  }
}
