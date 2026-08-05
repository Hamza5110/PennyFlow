import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/expense/expense_list_item.dart';
import '../../../services/expense/expense_service.dart';
import '../expense_routes.dart';

class ExpenseDetailController extends BaseController {
  ExpenseDetailController(this._expenses);

  final ExpenseService _expenses;

  final Rxn<ExpenseListItem> item = Rxn<ExpenseListItem>();
  int? _expenseId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ExpenseDetailArgs) {
      _expenseId = args.expenseId;
      load();
    }
  }

  Future<void> load() async {
    final id = _expenseId;
    if (id == null) return;

    await runGuarded(() async {
      final expense = await _expenses.getById(id);
      if (expense == null) {
        ErrorHandler.showError('expense_not_found'.tr);
        Get.back<void>();
        return;
      }
      final items = await _expenses.listActive();
      item.value = items.firstWhere(
        (e) => e.expense.id == id,
        orElse: () => ExpenseListItem(
          expense: expense,
          categoryName: 'Unknown',
          categoryColorHex: '#64748B',
          accountName: 'Unknown',
        ),
      );
    }, showErrorSnackbar: false);
  }

  void edit() {
    final id = _expenseId;
    if (id == null) return;
    Get.toNamed<void>(
      AppRoutes.expenseForm,
      arguments: ExpenseFormArgs(expenseId: id),
    )?.then((_) => load());
  }

  Future<void> duplicate() async {
    final id = _expenseId;
    if (id == null) return;
    await runGuarded(() async {
      final result = await _expenses.duplicate(id);
      if (result.success) {
        ErrorHandler.showSuccess('expense_duplicated'.tr);
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> delete() async {
    final id = _expenseId;
    if (id == null) return;
    await runGuarded(() async {
      final result = await _expenses.softDelete(id);
      if (result.success) {
        ErrorHandler.showSuccess('expense_deleted'.tr);
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
