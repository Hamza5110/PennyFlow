import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/accounts_list_controller.dart';
import '../widgets/account_list_tile.dart';

class AccountsListView extends GetView<AccountsListController> {
  const AccountsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'accounts_title'.tr,
      actions: [
        Obx(
          () => TextButton(
            onPressed: controller.toggleArchived,
            child: Text(
              controller.showArchived.value
                  ? 'accounts_show_active'.tr
                  : 'accounts_show_archived'.tr,
            ),
          ),
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.activeItems.isEmpty &&
            controller.archivedItems.isEmpty) {
          return AppLoadingIndicator(message: 'common_loading'.tr);
        }

        final items = controller.showArchived.value
            ? controller.archivedItems
            : controller.activeItems;

        if (items.isEmpty) {
          return AppEmptyState(
            title: controller.showArchived.value
                ? 'accounts_archived_empty'.tr
                : 'accounts_empty_title'.tr,
            message: controller.showArchived.value
                ? 'accounts_archived_empty_message'.tr
                : 'accounts_empty_message'.tr,
            icon: Icons.account_balance_wallet_outlined,
            actionLabel:
                controller.showArchived.value ? null : 'accounts_add'.tr,
            onAction: controller.showArchived.value ? null : controller.openAdd,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadAccounts,
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final isArchived = controller.showArchived.value;
              return Column(
                children: [
                  AccountListTile(
                    item: item,
                    currencyCode: currency,
                    isArchived: isArchived,
                    onTap: () => controller.openEdit(item),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isArchived)
                        TextButton(
                          onPressed: () => controller.unarchiveAccount(item),
                          child: Text('accounts_unarchive'.tr),
                        )
                      else ...[
                        TextButton(
                          onPressed: () => controller.archiveAccount(item),
                          child: Text('accounts_archive'.tr),
                        ),
                        if (!item.account.isDefault)
                          TextButton(
                            onPressed: () => controller.deleteAccount(item),
                            child: Text('common_delete'.tr),
                          ),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }),
      floatingActionButton: Obx(
        () => controller.showArchived.value
            ? const SizedBox.shrink()
            : FloatingActionButton(
                onPressed: controller.openAdd,
                child: const Icon(Icons.add_rounded),
              ),
      ),
    );
  }
}
