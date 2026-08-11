import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/reminder/reminder_list_item.dart';
import '../../../services/reminder/reminder_service.dart';
import '../reminder_routes.dart';

class RemindersListController extends BaseController {
  RemindersListController(this._reminders);

  final ReminderService _reminders;

  final RxBool showCompleted = false.obs;
  final RxList<ReminderListItem> items = <ReminderListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReminders();
  }

  Future<void> loadReminders() async {
    await runGuarded(() async {
      items.assignAll(
        await _reminders.listReminders(
          includeCompleted: showCompleted.value,
        ),
      );
    }, showErrorSnackbar: false);
  }

  Future<void> toggleShowCompleted(bool value) async {
    showCompleted.value = value;
    await loadReminders();
  }

  void openAdd() {
    Get.toNamed<void>(AppRoutes.reminderForm)?.then((_) => loadReminders());
  }

  void openEdit(ReminderListItem item) {
    if (item.reminder.linkedFriendTransactionId != null) {
      ErrorHandler.showError('reminder_friend_linked_edit'.tr);
      return;
    }
    Get.toNamed<void>(
      AppRoutes.reminderForm,
      arguments: ReminderFormArgs(reminderId: item.reminder.id),
    )?.then((_) => loadReminders());
  }

  Future<void> dismiss(ReminderListItem item) async {
    await runGuarded(() async {
      final result = await _reminders.dismiss(item.reminder.id);
      if (result.success) {
        ErrorHandler.showSuccess('reminder_dismissed'.tr);
        await loadReminders();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> snooze(ReminderListItem item, Duration duration) async {
    await runGuarded(() async {
      final result = await _reminders.snooze(item.reminder.id, duration: duration);
      if (result.success) {
        ErrorHandler.showSuccess('reminder_snoozed'.tr);
        await loadReminders();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> deleteReminder(ReminderListItem item) async {
    await runGuarded(() async {
      final result = await _reminders.delete(item.reminder.id);
      if (result.success) {
        ErrorHandler.showSuccess('reminder_deleted'.tr);
        await loadReminders();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
