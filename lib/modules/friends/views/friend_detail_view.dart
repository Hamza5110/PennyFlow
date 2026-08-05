import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/friend_detail_controller.dart';
import '../widgets/friend_transaction_list_tile.dart';

class FriendDetailView extends GetView<FriendDetailController> {
  const FriendDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'friends_detail'.tr,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: controller.editFriend,
        ),
      ],
      body: Obx(() {
        final item = controller.friendItem.value;
        if (item == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final net = item.netPendingBalance;
        final netColor = net > 0
            ? AppColors.income
            : net < 0
                ? AppColors.expense
                : theme.colorScheme.onSurface;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.friend.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      if (item.friend.phone?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(item.friend.phone!),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        AppFormatters.currency(net.abs(), currencyCode: currency),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: netColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        net > 0
                            ? 'friends_owes_you'.tr
                            : net < 0
                                ? 'friends_you_owe'.tr
                                : 'friends_settled'.tr,
                        style: theme.textTheme.bodyMedium?.copyWith(color: netColor),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'friends_money_given'.tr,
                              onPressed: controller.addGiven,
                              icon: Icons.arrow_upward_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              label: 'friends_money_received'.tr,
                              onPressed: controller.addReceived,
                              variant: AppButtonVariant.outlined,
                              icon: Icons.arrow_downward_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'friends_transaction_history'.tr,
                style: theme.textTheme.titleSmall,
              ),
            ),
            Expanded(
              child: controller.transactions.isEmpty
                  ? AppEmptyState(
                      title: 'friends_transactions_empty_title'.tr,
                      icon: Icons.swap_horiz_rounded,
                    )
                  : ListView.separated(
                      itemCount: controller.transactions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final txn = controller.transactions[index];
                        return FriendTransactionListTile(
                          item: txn,
                          currencyCode: currency,
                          onTap: () => controller.openTransaction(txn),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
