import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/friend_trash_controller.dart';
import '../widgets/friend_transaction_list_tile.dart';

class FriendTrashView extends GetView<FriendTrashController> {
  const FriendTrashView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'friends_trash'.tr,
      body: Obx(() {
        if (controller.items.isEmpty) {
          return AppEmptyState(
            title: 'friends_trash_empty'.tr,
            icon: Icons.delete_outline_rounded,
          );
        }

        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Column(
              children: [
                FriendTransactionListTile(
                  item: item,
                  currencyCode: currency,
                  onTap: () {},
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => controller.restore(item),
                      child: Text('friends_restore'.tr),
                    ),
                    TextButton(
                      onPressed: () => controller.deletePermanently(item),
                      child: Text('friends_delete_permanently'.tr),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
