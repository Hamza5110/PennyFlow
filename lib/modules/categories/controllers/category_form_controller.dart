import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/category_icons.dart';
import '../../../data/models/category.dart';
import '../../../data/models/category/category_input.dart';
import '../../../services/category/category_service.dart';
import '../category_routes.dart';

class CategoryFormController extends BaseController {
  CategoryFormController(this._categories);

  final CategoryService _categories;

  final nameController = TextEditingController();

  final RxString selectedColorHex = CategoryIcons.colorPalette.first.obs;
  final RxString selectedIconKey = CategoryIcons.availableKeys.first.obs;

  int? _categoryId;
  bool get isEditing => _categoryId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is CategoryFormArgs) {
      _categoryId = args.categoryId;
    }
    _bootstrap();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    final id = _categoryId;
    if (id == null) return;

    await runGuarded(() async {
      final category = await _categories.getById(id);
      if (category == null) {
        ErrorHandler.showError('categories_not_found'.tr);
        Get.back<void>();
        return;
      }
      _populate(category);
    }, showErrorSnackbar: false);
  }

  void _populate(Category category) {
    nameController.text = category.name;
    selectedColorHex.value = category.colorHex;
    selectedIconKey.value = category.iconKey;
  }

  void selectColor(String hex) => selectedColorHex.value = hex;

  void selectIcon(String key) => selectedIconKey.value = key;

  CategoryInput _buildInput() {
    return CategoryInput(
      name: nameController.text.trim(),
      colorHex: selectedColorHex.value,
      iconKey: selectedIconKey.value,
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = _buildInput();
      final result = isEditing
          ? await _categories.update(_categoryId!, input)
          : await _categories.create(input);

      if (result.success) {
        ErrorHandler.showSuccess(
          isEditing ? 'categories_updated'.tr : 'categories_created'.tr,
        );
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
