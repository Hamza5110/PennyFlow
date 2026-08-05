import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/friend_transactions_list_controller.dart';
import '../widgets/friend_filter_sheet.dart';
import '../widgets/friend_transaction_list_tile.dart';

class FriendTransactionsListView extends GetView<FriendTransactionsListController> {
  const FriendTransactionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'friends_search_hint'.tr,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onChanged: controller.onSearchChanged,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => FriendFilterSheet.show(
                  initial: controller.filter.value,
                  onApply: controller.applyFilter,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: controller.openTrash,
                tooltip: 'friends_trash'.tr,
              ),
            ],
          ),
        ),
        Obx(() {
          if (controller.filter.value.hasActiveFilters) {
            return Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: controller.clearFilters,
                child: Text('expense_clear_filters'.tr),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.items.isEmpty) {
              return AppLoadingIndicator(message: 'common_loading'.tr);
            }
            if (controller.items.isEmpty) {
              return AppEmptyState(
                title: 'friends_transactions_empty_title'.tr,
                message: 'friends_transactions_empty_message'.tr,
                icon: Icons.swap_horiz_rounded,
                actionLabel: 'friends_add_transaction'.tr,
                onAction: controller.openAdd,
              );
            }
            return RefreshIndicator(
              onRefresh: controller.loadTransactions,
              child: ListView.separated(
                itemCount: controller.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return FriendTransactionListTile(
                    item: item,
                    currencyCode: currency,
                    onTap: () => controller.openDetail(item),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
