import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/category.dart';
import '../../../services/category/category_service.dart';
import '../category_routes.dart';
import '../widgets/category_delete_dialog.dart';

class CategoriesListController extends BaseController {
  CategoriesListController(this._categories);

  final CategoryService _categories;

  final RxList<Category> items = <Category>[].obs;
  final RxMap<int, int> usageCounts = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    await runGuarded(() async {
      final categories = await _categories.getCategories();
      items.assignAll(categories);
      usageCounts.clear();
      for (final category in categories) {
        usageCounts[category.id] = await _categories.countUsage(category.id);
      }
    }, showErrorSnackbar: false);
  }

  void openAdd() {
    Get.toNamed<void>(AppRoutes.categoryForm)?.then((_) => loadCategories());
  }

  void openEdit(Category category) {
    Get.toNamed<void>(
      AppRoutes.categoryForm,
      arguments: CategoryFormArgs(categoryId: category.id),
    )?.then((_) => loadCategories());
  }

  Future<void> deleteCategory(Category category) async {
    if (category.isDefault) {
      ErrorHandler.showError('categories_default_delete_blocked'.tr);
      return;
    }

    final usage = usageCounts[category.id] ?? 0;
    int? reassignId;

    if (usage > 0) {
      final others = items.where((c) => c.id != category.id).toList();
      if (others.isEmpty) {
        ErrorHandler.showError('categories_reassign_unavailable'.tr);
        return;
      }
      reassignId = await CategoryDeleteDialog.show(
        categoryName: category.name,
        usageCount: usage,
        alternatives: others,
      );
      if (reassignId == null) return;
    } else {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('categories_delete_title'.tr),
          content: Text(
            'categories_delete_confirm'.trParams({'name': category.name}),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('common_cancel'.tr),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: Text('common_delete'.tr),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await runGuarded(() async {
      final result = await _categories.delete(
        category.id,
        reassignToCategoryId: reassignId,
      );
      if (result.success) {
        ErrorHandler.showSuccess('categories_deleted'.tr);
        await loadCategories();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
