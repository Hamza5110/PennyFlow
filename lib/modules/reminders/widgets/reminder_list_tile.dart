import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/reminder_constants.dart';
import '../../../data/models/reminder/reminder_list_item.dart';

class ReminderListTile extends StatelessWidget {
  const ReminderListTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismiss,
    required this.onSnooze,
    required this.onDelete,
  });

  final ReminderListItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final ValueChanged<Duration> onSnooze;
  final VoidCallback onDelete;

  IconData _iconForType(String type) {
    switch (type) {
      case ReminderTypes.billDue:
        return Icons.receipt_long_outlined;
      case ReminderTypes.friendPaymentDue:
        return Icons.people_outline_rounded;
      case ReminderTypes.subscriptionRenewal:
        return Icons.subscriptions_outlined;
      case ReminderTypes.insurance:
        return Icons.health_and_safety_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = item.reminder;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        _iconForType(reminder.type),
        color: item.isOverdue ? theme.colorScheme.error : null,
      ),
      title: Text(
        reminder.title,
        style: reminder.isCompleted
            ? theme.textTheme.titleMedium?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              )
            : null,
      ),
      subtitle: Text(item.subtitle),
      trailing: reminder.isCompleted
          ? IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
            )
          : PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'dismiss':
                    onDismiss();
                  case 'snooze_1h':
                    onSnooze(const Duration(hours: 1));
                  case 'snooze_1d':
                    onSnooze(const Duration(days: 1));
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'snooze_1h',
                  child: Text('reminder_snooze_1h'.tr),
                ),
                PopupMenuItem(
                  value: 'snooze_1d',
                  child: Text('reminder_snooze_1d'.tr),
                ),
                PopupMenuItem(
                  value: 'dismiss',
                  child: Text('reminder_dismiss'.tr),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('common_delete'.tr),
                ),
              ],
            ),
    );
  }
}
