import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/repositories/payment_account_repository.dart';
import '../../../services/image/image_service.dart';
import '../../../services/income/income_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../../services/search/filter_session_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/income_detail_controller.dart';
import '../controllers/income_form_controller.dart';
import '../controllers/income_trash_controller.dart';
import '../controllers/incomes_list_controller.dart';

class IncomeBinding extends Bindings {
  @override
  void dependencies() {
    final isar = Get.find<IsarDatabase>();

    if (!Get.isRegistered<PaymentAccountRepository>()) {
      Get.put(PaymentAccountRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<IncomeRepository>()) {
      Get.put(IncomeRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<ImageService>()) {
      Get.put(ImageService(), permanent: true);
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
    if (!Get.isRegistered<IncomeService>()) {
      Get.put(
        IncomeService(
          Get.find<IncomeRepository>(),
          Get.find<PaymentAccountService>(),
          Get.find<ImageService>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<IncomesListController>(
      () => IncomesListController(
        Get.find<IncomeService>(),
        Get.find<FilterSessionService>(),
      ),
    );
    Get.lazyPut<IncomeFormController>(
      () => IncomeFormController(
        Get.find<IncomeService>(),
        Get.find<PaymentAccountService>(),
        Get.find<ImageService>(),
        Get.find<SettingsService>(),
      ),
    );
    Get.lazyPut<IncomeDetailController>(
      () => IncomeDetailController(Get.find<IncomeService>()),
    );
    Get.lazyPut<IncomeTrashController>(
      () => IncomeTrashController(Get.find<IncomeService>()),
    );
  }
}
