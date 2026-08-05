import 'package:get/get.dart';

import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/repositories/friend_transaction_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/repositories/payment_account_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../data/repositories/repayment_repository.dart';
import '../../../services/report/report_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReportRepository>()) {
      Get.put(
        ReportRepository(
          Get.find<ProfileRepository>(),
          Get.find<ExpenseRepository>(),
          Get.find<IncomeRepository>(),
          Get.find<CategoryRepository>(),
          Get.find<PaymentAccountRepository>(),
          Get.find<FriendRepository>(),
          Get.find<FriendTransactionRepository>(),
          Get.find<RepaymentRepository>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ReportService>()) {
      Get.put(
        ReportService(
          Get.find<ReportRepository>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<ReportsController>(
      () => ReportsController(Get.find<ReportService>()),
    );
  }
}
