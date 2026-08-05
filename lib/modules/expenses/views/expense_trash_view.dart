import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/expense_trash_controller.dart';
import '../widgets/expense_list_tile.dart';

class ExpenseTrashView extends GetView<ExpenseTrashController> {
  const ExpenseTrashView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'expense_trash'.tr,
      body: Obx(() {
        if (controller.items.isEmpty) {
          return AppEmptyState(
            title: 'expense_trash_empty'.tr,
            icon: Icons.delete_outline_rounded,
          );
        }

        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Column(
              children: [
                ExpenseListTile(
                  item: item,
                  currencyCode: currency,
                  onTap: () {},
                  onDelete: () => controller.deletePermanently(item),
                  enableSwipeToDelete: false,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => controller.restore(item),
                      child: Text('expense_restore'.tr),
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
