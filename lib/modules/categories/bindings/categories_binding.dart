import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/expense_repository.dart';
import '../../../services/category/category_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/categories_list_controller.dart';
import '../controllers/category_form_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    final isar = Get.find<IsarDatabase>();

    if (!Get.isRegistered<CategoryRepository>()) {
      Get.put(CategoryRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<ExpenseRepository>()) {
      Get.put(ExpenseRepository(isar), permanent: true);
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

    Get.lazyPut<CategoriesListController>(
      () => CategoriesListController(Get.find<CategoryService>()),
    );
    Get.lazyPut<CategoryFormController>(
      () => CategoryFormController(Get.find<CategoryService>()),
    );
  }
}
