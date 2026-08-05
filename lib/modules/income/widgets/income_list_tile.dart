import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/income/income_list_item.dart';

class IncomeListTile extends StatelessWidget {
  const IncomeListTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.onTap,
    required this.onDelete,
    this.enableSwipeToDelete = true,
  });

  final IncomeListItem item;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool enableSwipeToDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(
      int.parse('FF${item.sourceColorHex.replaceFirst('#', '')}', radix: 16),
    );

    final tile = ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(Icons.arrow_downward_rounded, color: color, size: 20),
      ),
      title: Text(
        item.income.notes?.isNotEmpty == true
            ? item.income.notes!
            : item.sourceLabel,
      ),
      subtitle: Text(
        '${item.sourceLabel} · ${item.accountName} · ${AppFormatters.dateTime(item.income.date)}',
      ),
      trailing: Text(
        AppFormatters.currency(item.income.amount, currencyCode: currencyCode),
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.income,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (!enableSwipeToDelete) return tile;

    return Dismissible(
      key: ValueKey(item.income.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: tile,
    );
  }
}
