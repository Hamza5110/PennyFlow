import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../data/repositories/budget_envelope_repository.dart';
import '../../../data/repositories/budget_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/payment_account_repository.dart';
import '../../../services/budget/budget_service.dart';
import '../../../services/budget_envelope/budget_envelope_service.dart';
import '../../../services/category/category_service.dart';
import '../../../services/income/income_service.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/budget_form_controller.dart';
import '../controllers/budgets_list_controller.dart';
import '../controllers/envelope_form_controller.dart';

class BudgetsBinding extends Bindings {
  @override
  void dependencies() {
    final isar = Get.find<IsarDatabase>();

    if (!Get.isRegistered<BudgetRepository>()) {
      Get.put(BudgetRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<BudgetEnvelopeRepository>()) {
      Get.put(BudgetEnvelopeRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.put(CategoryRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.put(ExpenseRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<PaymentAccountRepository>()) {
      Get.put(PaymentAccountRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<NotificationService>()) {
      Get.putAsync<NotificationService>(() async => NotificationService().init());
    }
    if (!Get.isRegistered<BudgetService>()) {
      Get.put(
        BudgetService(
          Get.find<BudgetRepository>(),
          Get.find<ExpenseRepository>(),
          Get.find<CategoryRepository>(),
          Get.find<NotificationService>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<BudgetEnvelopeService>()) {
      Get.put(
        BudgetEnvelopeService(
          Get.find<BudgetEnvelopeRepository>(),
          Get.find<ExpenseRepository>(),
          Get.find<PaymentAccountRepository>(),
          Get.find<IncomeService>(),
          Get.find<NotificationService>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<BudgetsListController>(
      () => BudgetsListController(
        Get.find<BudgetService>(),
        Get.find<BudgetEnvelopeService>(),
      ),
    );
    Get.lazyPut<BudgetFormController>(
      () => BudgetFormController(
        Get.find<BudgetService>(),
        Get.find<CategoryService>(),
      ),
    );
    Get.lazyPut<EnvelopeFormController>(
      () => EnvelopeFormController(
        Get.find<BudgetEnvelopeService>(),
        Get.find<PaymentAccountService>(),
      ),
    );
  }
}
