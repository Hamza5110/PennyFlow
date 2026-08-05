import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/account_icons.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/payment_account/payment_account_list_item.dart';
import '../../../services/payment_account/payment_account_service.dart';

class AccountListTile extends StatelessWidget {
  const AccountListTile({
    super.key,
    required this.item,
    required this.currencyCode,
    required this.onTap,
    this.onArchive,
    this.onUnarchive,
    this.onDelete,
    this.isArchived = false,
  });

  final PaymentAccountListItem item;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;
  final VoidCallback? onDelete;
  final bool isArchived;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final account = item.account;
    final balanceColor =
        item.balance >= 0 ? AppColors.income : AppColors.expense;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Icon(AccountIcons.fromType(account.type)),
      ),
      title: Text(account.name),
      subtitle: Text(
        '${Get.find<PaymentAccountService>().typeLabel(account.type)}'
        '${account.isDefault ? ' · ${'accounts_default_badge'.tr}' : ''}'
        '${isArchived ? ' · ${'accounts_archived_badge'.tr}' : ''}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppFormatters.currency(item.balance, currencyCode: currencyCode),
            style: theme.textTheme.titleSmall?.copyWith(
              color: balanceColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.transactionCount > 0)
            Text(
              'accounts_transaction_count'
                  .trParams({'count': '${item.transactionCount}'}),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
      isThreeLine: true,
    );
  }
}
