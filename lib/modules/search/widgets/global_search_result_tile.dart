import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/search/global_search_result.dart';

class GlobalSearchResultTile extends StatelessWidget {
  const GlobalSearchResultTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.onTap,
  });

  final GlobalSearchResult item;
  final String currencyCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(item.type);

    return ListTile(
      onTap: onTap,
      leading: Icon(_iconForType(item.type), color: color),
      title: Text(item.title, style: theme.textTheme.titleMedium),
      subtitle: Text('${item.subtitle} · ${AppFormatters.date(item.date)}'),
      trailing: Text(
        AppFormatters.currency(item.amount, currencyCode: currencyCode),
        style: theme.textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _colorForType(GlobalSearchResultType type) {
    switch (type) {
      case GlobalSearchResultType.expense:
        return AppColors.expense;
      case GlobalSearchResultType.income:
        return AppColors.income;
      case GlobalSearchResultType.friendTransaction:
        return AppColors.transfer;
    }
  }

  IconData _iconForType(GlobalSearchResultType type) {
    switch (type) {
      case GlobalSearchResultType.expense:
        return Icons.arrow_downward_rounded;
      case GlobalSearchResultType.income:
        return Icons.arrow_upward_rounded;
      case GlobalSearchResultType.friendTransaction:
        return Icons.people_outline_rounded;
    }
  }
}
