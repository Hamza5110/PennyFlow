import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/recurring_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/recurring/recurring_list_item.dart';
import '../../../services/settings/settings_service.dart';

class RecurringListTile extends StatelessWidget {
  const RecurringListTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.onTap,
    required this.onToggleActive,
    required this.onDelete,
  });

  final RecurringListItem item;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  String _frequencyLabel(String frequency) {
    switch (frequency) {
      case RecurringFrequencies.daily:
        return 'recurring_freq_daily'.tr;
      case RecurringFrequencies.weekly:
        return 'recurring_freq_weekly'.tr;
      case RecurringFrequencies.monthly:
        return 'recurring_freq_monthly'.tr;
      case RecurringFrequencies.yearly:
        return 'recurring_freq_yearly'.tr;
      default:
        return frequency;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final template = item.template;

    return ListTile(
      onTap: onTap,
      title: Text(item.label),
      subtitle: Text(
        '${_frequencyLabel(template.frequency)} · ${item.accountName}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppFormatters.currency(template.amount, currencyCode: currencyCode),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            icon: Icon(
              template.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
            ),
            tooltip: template.isActive
                ? 'recurring_pause'.tr
                : 'recurring_resume'.tr,
            onPressed: onToggleActive,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'common_delete'.tr,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
