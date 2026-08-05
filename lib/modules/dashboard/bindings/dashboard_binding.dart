import 'package:get/get.dart';

import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/dashboard_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/repositories/payment_account_repository.dart';
import '../../../services/dashboard/dashboard_service.dart';
import '../../../services/friend/friend_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DashboardRepository>()) {
      Get.put<DashboardRepository>(
        DashboardRepository(
          Get.find<ExpenseRepository>(),
          Get.find<IncomeRepository>(),
          Get.find<CategoryRepository>(),
          Get.find<PaymentAccountRepository>(),
          Get.find<FriendService>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<DashboardService>()) {
      Get.put<DashboardService>(
        DashboardService(
          Get.find<DashboardRepository>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        Get.find<DashboardService>(),
        Get.find<SettingsService>(),
      ),
    );
  }
}
