import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/budget/budget_list_item.dart';
import '../../../services/budget/budget_service.dart';
import '../budget_routes.dart';

class BudgetsListController extends BaseController {
  BudgetsListController(this._budgets);

  final BudgetService _budgets;

  final RxList<BudgetListItem> items = <BudgetListItem>[].obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;

  @override
  void onInit() {
    super.onInit();
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    await runGuarded(() async {
      items.assignAll(
        await _budgets.listForMonth(
          year: selectedYear.value,
          month: selectedMonth.value,
        ),
      );
    }, showErrorSnackbar: false);
  }

  void openAdd() {
    Get.toNamed<void>(AppRoutes.budgetForm)?.then((_) => loadBudgets());
  }

  void openEdit(BudgetListItem item) {
    Get.toNamed<void>(
      AppRoutes.budgetForm,
      arguments: BudgetFormArgs(budgetId: item.budget.id),
    )?.then((_) => loadBudgets());
  }

  Future<void> deleteBudget(BudgetListItem item) async {
    await runGuarded(() async {
      final result = await _budgets.delete(item.budget.id);
      if (result.success) {
        ErrorHandler.showSuccess('budgets_deleted'.tr);
        await loadBudgets();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
