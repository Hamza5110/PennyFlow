import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/friend_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/friend/friend_models.dart';

class FriendTransactionListTile extends StatelessWidget {
  const FriendTransactionListTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.onTap,
  });

  final FriendTransactionListItem item;
  final String currencyCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txn = item.transaction;
    final isGiven = txn.type == FriendTransactionTypes.given;
    final color = isGiven ? AppColors.income : AppColors.expense;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        isGiven ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        color: color,
      ),
      title: Text(
        item.friendName,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        '${_statusLabel(txn.status)} · ${AppFormatters.date(txn.date)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppFormatters.currency(txn.amount, currencyCode: currencyCode),
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.remainingBalance > 0)
            Text(
              'friends_remaining'.trParams({
                'amount': AppFormatters.currency(
                  item.remainingBalance,
                  currencyCode: currencyCode,
                ),
              }),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case FriendTransactionStatus.completed:
        return 'friends_status_completed'.tr;
      case FriendTransactionStatus.partiallyPaid:
        return 'friends_status_partial'.tr;
      default:
        return 'friends_status_pending'.tr;
    }
  }
}
