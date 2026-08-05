import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/repositories/payment_account_repository.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/account_form_controller.dart';
import '../controllers/accounts_list_controller.dart';

class AccountsBinding extends Bindings {
  @override
  void dependencies() {
    final isar = Get.find<IsarDatabase>();

    if (!Get.isRegistered<PaymentAccountRepository>()) {
      Get.put(PaymentAccountRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.put(ExpenseRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<IncomeRepository>()) {
      Get.put(IncomeRepository(isar), permanent: true);
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

    Get.lazyPut<AccountsListController>(
      () => AccountsListController(Get.find<PaymentAccountService>()),
    );
    Get.lazyPut<AccountFormController>(
      () => AccountFormController(Get.find<PaymentAccountService>()),
    );
  }
}
