import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/repositories/payment_account_repository.dart';
import '../../../services/category/category_service.dart';
import '../../../services/expense/expense_service.dart';
import '../../../services/image/image_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../../services/search/filter_session_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/expense_detail_controller.dart';
import '../controllers/expense_form_controller.dart';
import '../controllers/expense_trash_controller.dart';
import '../controllers/expenses_list_controller.dart';

class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    final isar = Get.find<IsarDatabase>();

    if (!Get.isRegistered<CategoryRepository>()) {
      Get.put(CategoryRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<PaymentAccountRepository>()) {
      Get.put(PaymentAccountRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.put(ExpenseRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<ImageService>()) {
      Get.put(ImageService(), permanent: true);
    }
    if (!Get.isRegistered<CategoryService>()) {
      Get.put(
        CategoryService(
          Get.find<CategoryRepository>(),
          Get.find<ExpenseRepository>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<PaymentAccountService>()) {
      Get.put(
        PaymentAccountService(
          Get.find<PaymentAccountRepository>(),
          Get.find<ExpenseRepository>(),
          Get.find<IncomeRepository>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ExpenseService>()) {
      Get.put(
        ExpenseService(
          Get.find<ExpenseRepository>(),
          Get.find<CategoryService>(),
          Get.find<PaymentAccountService>(),
          Get.find<ImageService>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<ExpensesListController>(
      () => ExpensesListController(
        Get.find<ExpenseService>(),
        Get.find<FilterSessionService>(),
      ),
    );
    Get.lazyPut<ExpenseFormController>(
      () => ExpenseFormController(
        Get.find<ExpenseService>(),
        Get.find<CategoryService>(),
        Get.find<PaymentAccountService>(),
        Get.find<ImageService>(),
        Get.find<SettingsService>(),
      ),
    );
    Get.lazyPut<ExpenseDetailController>(
      () => ExpenseDetailController(Get.find<ExpenseService>()),
    );
    Get.lazyPut<ExpenseTrashController>(
      () => ExpenseTrashController(Get.find<ExpenseService>()),
    );
  }
}
