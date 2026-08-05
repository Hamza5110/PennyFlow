import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/friend/friend_models.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.onTap,
  });

  final FriendListItem item;
  final String currencyCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final net = item.netPendingBalance;
    final netColor = net > 0
        ? AppColors.income
        : net < 0
            ? AppColors.expense
            : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Text(
          item.friend.name.isNotEmpty ? item.friend.name[0].toUpperCase() : '?',
        ),
      ),
      title: Text(item.friend.name, style: theme.textTheme.titleMedium),
      subtitle: Text(
        item.friend.phone?.isNotEmpty == true
            ? item.friend.phone!
            : '${item.transactionCount} transactions',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppFormatters.currency(net.abs(), currencyCode: currencyCode),
            style: theme.textTheme.titleSmall?.copyWith(
              color: netColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            net > 0
                ? 'friends_owes_you'.tr
                : net < 0
                    ? 'friends_you_owe'.tr
                    : 'friends_settled'.tr,
            style: theme.textTheme.bodySmall?.copyWith(color: netColor),
          ),
        ],
      ),
    );
  }
}
