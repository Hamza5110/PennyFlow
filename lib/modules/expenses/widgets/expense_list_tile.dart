import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/expense/expense_list_item.dart';

class ExpenseListTile extends StatelessWidget {
  const ExpenseListTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.onTap,
    required this.onDelete,
    this.enableSwipeToDelete = true,
  });

  final ExpenseListItem item;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool enableSwipeToDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryIcons.parseColor(item.categoryColorHex);

    final tile = ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(Icons.arrow_upward_rounded, color: color, size: 20),
      ),
      title: Text(item.expense.notes?.isNotEmpty == true
          ? item.expense.notes!
          : item.categoryName),
      subtitle: Text(
        '${item.categoryName} · ${item.accountName} · ${AppFormatters.dateTime(item.expense.date)}',
      ),
      trailing: Text(
        AppFormatters.currency(item.expense.amount, currencyCode: currencyCode),
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.expense,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (!enableSwipeToDelete) return tile;

    return Dismissible(
      key: ValueKey(item.expense.id),
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
