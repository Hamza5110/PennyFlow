import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/budget/budget_list_item.dart';
import '../../../data/models/budget_envelope/budget_envelope_list_item.dart';
import '../../../services/budget/budget_service.dart';
import '../../../services/budget_envelope/budget_envelope_service.dart';
import '../budget_routes.dart';

class BudgetsListController extends BaseController {
  BudgetsListController(this._budgets, this._envelopes);

  final BudgetService _budgets;
  final BudgetEnvelopeService _envelopes;

  final RxList<BudgetListItem> items = <BudgetListItem>[].obs;
  final RxList<BudgetEnvelopeListItem> envelopes = <BudgetEnvelopeListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    await runGuarded(() async {
      envelopes.assignAll(await _envelopes.listActive());
      items.assignAll(await _budgets.listActive());
    }, showErrorSnackbar: false);
  }

  String periodLabel(BudgetListItem item) =>
      _budgets.periodLabel(item.budget, window: item.window);

  String envelopePeriodLabel(BudgetEnvelopeListItem item) =>
      _envelopes.periodLabel(item.envelope, window: item.window);

  void openAdd() {
    Get.toNamed<void>(AppRoutes.budgetForm)?.then((_) => loadBudgets());
  }

  void openAddEnvelope() {
    Get.toNamed<void>(AppRoutes.envelopeForm)?.then((_) => loadBudgets());
  }

  void openEdit(BudgetListItem item) {
    Get.toNamed<void>(
      AppRoutes.budgetForm,
      arguments: BudgetFormArgs(budgetId: item.budget.id),
    )?.then((_) => loadBudgets());
  }

  void openEditEnvelope(BudgetEnvelopeListItem item) {
    Get.toNamed<void>(
      AppRoutes.envelopeForm,
      arguments: EnvelopeFormArgs(envelopeId: item.envelope.id),
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

  Future<void> deleteEnvelope(BudgetEnvelopeListItem item) async {
    await runGuarded(() async {
      final result = await _envelopes.delete(item.envelope.id);
      if (result.success) {
        ErrorHandler.showSuccess('envelope_deleted'.tr);
        await loadBudgets();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
