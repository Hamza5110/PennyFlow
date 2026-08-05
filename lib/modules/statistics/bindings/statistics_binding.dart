import 'package:get/get.dart';

import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../data/repositories/income_repository.dart';
import '../../../data/repositories/statistics_repository.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/statistics/statistics_service.dart';
import '../controllers/statistics_controller.dart';

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StatisticsRepository>()) {
      Get.put(
        StatisticsRepository(
          Get.find<ExpenseRepository>(),
          Get.find<IncomeRepository>(),
          Get.find<CategoryRepository>(),
        ),
        permanent: true,
      );
    }
    if (!Get.isRegistered<StatisticsService>()) {
      Get.put(
        StatisticsService(
          Get.find<StatisticsRepository>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<StatisticsController>(
      () => StatisticsController(Get.find<StatisticsService>()),
    );
  }
}
