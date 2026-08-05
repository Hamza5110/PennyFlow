import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/repositories/payment_account_repository.dart';
import '../../../data/repositories/recurring_template_repository.dart';
import '../../../services/category/category_service.dart';
import '../../../services/expense/expense_service.dart';
import '../../../services/income/income_service.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../../services/recurring/recurring_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/recurring_form_controller.dart';
import '../controllers/recurring_list_controller.dart';

class RecurringBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RecurringTemplateRepository>()) {
      Get.put(
        RecurringTemplateRepository(Get.find<IsarDatabase>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<RecurringService>()) {
      Get.put(
        RecurringService(
          Get.find<RecurringTemplateRepository>(),
          Get.find<ExpenseService>(),
          Get.find<IncomeService>(),
          Get.find<ExpenseRepository>(),
          Get.find<IncomeRepository>(),
          Get.find<CategoryRepository>(),
          Get.find<PaymentAccountRepository>(),
          Get.find<NotificationService>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<RecurringListController>(
      () => RecurringListController(Get.find<RecurringService>()),
    );
    Get.lazyPut<RecurringFormController>(
      () => RecurringFormController(
        Get.find<RecurringService>(),
        Get.find<CategoryService>(),
        Get.find<PaymentAccountService>(),
      ),
    );
  }
}
