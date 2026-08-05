import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/expense/expense_list_item.dart';
import '../../../services/expense/expense_service.dart';

class ExpenseTrashController extends BaseController {
  ExpenseTrashController(this._expenses);

  final ExpenseService _expenses;

  final RxList<ExpenseListItem> items = <ExpenseListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrash();
  }

  Future<void> loadTrash() async {
    await runGuarded(() async {
      items.assignAll(await _expenses.listTrash());
    }, showErrorSnackbar: false);
  }

  Future<void> restore(ExpenseListItem item) async {
    await runGuarded(() async {
      final result = await _expenses.restore(item.expense.id);
      if (result.success) {
        ErrorHandler.showSuccess('expense_restored'.tr);
        await loadTrash();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> deletePermanently(ExpenseListItem item) async {
    await runGuarded(() async {
      final result = await _expenses.permanentDelete(item.expense.id);
      if (result.success) {
        ErrorHandler.showSuccess('expense_purged'.tr);
        await loadTrash();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
