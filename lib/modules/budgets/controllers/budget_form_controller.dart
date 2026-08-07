import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/budget.dart';
import '../../../data/models/budget/budget_input.dart';
import '../../../data/models/category.dart';
import '../../../services/budget/budget_service.dart';
import '../../../services/category/category_service.dart';
import '../budget_routes.dart';

class BudgetFormController extends BaseController {
  BudgetFormController(this._budgets, this._categories);

  final BudgetService _budgets;
  final CategoryService _categories;

  final targetController = TextEditingController();
  final thresholdController = TextEditingController(
    text: (AppConstants.defaultBudgetWarningThreshold * 100).toStringAsFixed(0),
  );

  final RxList<Category> categories = <Category>[].obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;

  int? _budgetId;
  bool get isEditing => _budgetId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is BudgetFormArgs) _budgetId = args.budgetId;
    _bootstrap();
  }

  @override
  void onClose() {
    targetController.dispose();
    thresholdController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await runGuarded(() async {
      categories.assignAll(await _categories.getCategories());
      if (_budgetId != null) {
        final budget = await _budgets.getById(_budgetId!);
        if (budget == null) {
          ErrorHandler.showError('budgets_not_found'.tr);
          Get.back<void>();
          return;
        }
        _populate(budget);
      } else if (categories.isNotEmpty) {
        selectedCategoryId.value = categories.first.id;
      }
    }, showErrorSnackbar: false);
  }

  void _populate(Budget budget) {
    targetController.text = budget.targetAmount.toStringAsFixed(2);
    thresholdController.text =
        (budget.warningThreshold * 100).toStringAsFixed(0);
    selectedCategoryId.value = budget.categoryId;
    selectedYear.value = budget.year;
    selectedMonth.value = budget.month;
  }

  BudgetInput _buildInput() {
    return BudgetInput(
      categoryId: selectedCategoryId.value!,
      targetAmount: double.parse(targetController.text.trim()),
      year: selectedYear.value,
      month: selectedMonth.value,
      warningThreshold:
          double.parse(thresholdController.text.trim()) / 100,
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = _buildInput();
      final result = isEditing
          ? await _budgets.update(_budgetId!, input)
          : await _budgets.create(input);
      if (result.success) {
        ErrorHandler.popWithSuccess(
          isEditing ? 'budgets_updated'.tr : 'budgets_created'.tr,
        );
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
