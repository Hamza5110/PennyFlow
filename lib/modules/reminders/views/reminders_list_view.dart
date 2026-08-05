import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/reminders_list_controller.dart';
import '../widgets/reminder_list_tile.dart';

class RemindersListView extends GetView<RemindersListController> {
  const RemindersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'reminders_title'.tr,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('reminders_show_completed'.tr),
                value: controller.showCompleted.value,
                onChanged: controller.toggleShowCompleted,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.items.isEmpty) {
                return AppLoadingIndicator(message: 'common_loading'.tr);
              }
              if (controller.items.isEmpty) {
                return AppEmptyState(
                  title: 'reminders_empty_title'.tr,
                  message: 'reminders_empty_message'.tr,
                  icon: Icons.notifications_outlined,
                  actionLabel: 'reminders_add'.tr,
                  onAction: controller.openAdd,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadReminders,
                child: ListView.separated(
                  itemCount: controller.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = controller.items[index];
                    return ReminderListTile(
                      item: item,
                      onTap: () => controller.openEdit(item),
                      onDismiss: () => controller.dismiss(item),
                      onSnooze: (duration) =>
                          controller.snooze(item, duration),
                      onDelete: () => controller.deleteReminder(item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.openAdd,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
