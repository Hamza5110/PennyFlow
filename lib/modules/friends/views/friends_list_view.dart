import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/friends_list_controller.dart';
import '../widgets/friend_list_tile.dart';

class FriendsListView extends GetView<FriendsListController> {
  const FriendsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  onPressed: controller.openAddFriend,
                  tooltip: 'friends_add'.tr,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: controller.openTrash,
                  tooltip: 'friends_trash'.tr,
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return AppLoadingIndicator(message: 'common_loading'.tr);
              }
              if (controller.items.isEmpty) {
                return AppEmptyState(
                  title: 'friends_empty_title'.tr,
                  message: 'friends_empty_message'.tr,
                  icon: Icons.people_outline_rounded,
                  actionLabel: 'friends_add'.tr,
                  onAction: controller.openAddFriend,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadFriends,
                child: ListView.separated(
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return FriendListTile(
                      item: item,
                      currencyCode: currency,
                      onTap: () => controller.openFriend(item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: controller.openAddTransaction,
        icon: const Icon(Icons.add_rounded),
        label: Text('friends_add_transaction'.tr),
      ),
    );
  }
}
