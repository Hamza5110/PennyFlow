import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/reminder/reminder_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/reminder_form_controller.dart';
import '../controllers/reminders_list_controller.dart';

class RemindersBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReminderRepository>()) {
      Get.put(
        ReminderRepository(Get.find<IsarDatabase>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ReminderService>()) {
      Get.put(
        ReminderService(
          Get.find<ReminderRepository>(),
          Get.find<FriendRepository>(),
          Get.find<NotificationService>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<RemindersListController>(
      () => RemindersListController(Get.find<ReminderService>()),
    );
    Get.lazyPut<ReminderFormController>(
      () => ReminderFormController(Get.find<ReminderService>()),
    );
  }
}
