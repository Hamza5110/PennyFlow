import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/budget_period_utils.dart';
import '../../../data/models/budget.dart';
import '../../../data/models/budget/budget_input.dart';
import '../../../data/models/category.dart';
import '../../../data/models/enums/app_enums.dart';
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
  final Rx<BudgetPeriodType> periodType = BudgetPeriodType.monthly.obs;
  final Rx<DateTime> periodStart = DateTime.now().obs;
  final Rx<DateTime> periodEnd = DateTime.now().obs;
  final RxBool autoRepeat = true.obs;

  int? _budgetId;
  bool get isEditing => _budgetId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is BudgetFormArgs) _budgetId = args.budgetId;
    _syncPeriodEndFromType();
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
    periodType.value = BudgetPeriodUtils.typeOf(budget);
    periodStart.value = BudgetPeriodUtils.startOfDay(budget.periodStart);
    periodEnd.value = BudgetPeriodUtils.startOfDay(budget.periodEnd);
    autoRepeat.value = budget.autoRepeat;
  }

  void setPeriodType(BudgetPeriodType type) {
    periodType.value = type;
    _syncPeriodEndFromType();
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: periodStart.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    periodStart.value = BudgetPeriodUtils.startOfDay(picked);
    if (periodType.value != BudgetPeriodType.custom ||
        periodEnd.value.isBefore(periodStart.value)) {
      _syncPeriodEndFromType();
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: periodEnd.value.isBefore(periodStart.value)
          ? periodStart.value
          : periodEnd.value,
      firstDate: periodStart.value,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    periodEnd.value = BudgetPeriodUtils.startOfDay(picked);
  }

  void _syncPeriodEndFromType() {
    periodEnd.value = BudgetPeriodUtils.startOfDay(
      BudgetPeriodUtils.defaultPeriodEnd(
        type: periodType.value,
        periodStart: periodStart.value,
        customEnd: periodEnd.value,
      ),
    );
  }

  BudgetInput _buildInput() {
    final type = periodType.value;
    final start = BudgetPeriodUtils.startOfDay(periodStart.value);
    final end = BudgetPeriodUtils.defaultPeriodEnd(
      type: type,
      periodStart: start,
      customEnd: periodEnd.value,
    );

    return BudgetInput(
      categoryId: selectedCategoryId.value!,
      targetAmount: double.parse(targetController.text.trim()),
      periodType: type,
      periodStart: start,
      periodEnd: end,
      autoRepeat: autoRepeat.value,
      warningThreshold: double.parse(thresholdController.text.trim()) / 100,
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
