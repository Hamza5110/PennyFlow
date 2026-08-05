import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/debounce.dart';
import '../../../data/models/expense/expense_filter.dart';
import '../../../data/models/expense/expense_list_item.dart';
import '../../../services/expense/expense_service.dart';
import '../../../services/search/filter_session_service.dart';
import '../expense_routes.dart';

class ExpensesListController extends BaseController {
  ExpensesListController(this._expenses, this._session);

  final ExpenseService _expenses;
  final FilterSessionService _session;
  final _debouncer = Debouncer();

  final RxList<ExpenseListItem> items = <ExpenseListItem>[].obs;
  final Rx<ExpenseFilter> filter = ExpenseFilter.empty.obs;
  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filter.value = _session.expenseFilter;
    searchText.value = _session.expenseFilter.searchQuery;
    loadExpenses();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  Future<void> loadExpenses() async {
    await runGuarded(() async {
      items.assignAll(await _expenses.listActive(filter: filter.value));
    }, showErrorSnackbar: false);
  }

  void onSearchChanged(String value) {
    searchText.value = value;
    _debouncer.call(() {
      filter.value = filter.value.copyWith(searchQuery: value);
      _session.expenseFilter = filter.value;
      loadExpenses();
    });
  }

  void applyFilter(ExpenseFilter updated) {
    filter.value = updated.copyWith(searchQuery: searchText.value);
    _session.expenseFilter = filter.value;
    loadExpenses();
  }

  void clearFilters() {
    searchText.value = '';
    filter.value = ExpenseFilter.empty;
    _session.expenseFilter = ExpenseFilter.empty;
    loadExpenses();
  }

  void openAdd() => Get.toNamed<void>(AppRoutes.expenseForm);

  void openDetail(ExpenseListItem item) {
    Get.toNamed<void>(
      AppRoutes.expenseDetail,
      arguments: ExpenseDetailArgs(expenseId: item.expense.id),
    )?.then((_) => loadExpenses());
  }

  void openTrash() {
    Get.toNamed<void>(AppRoutes.expenseTrash)?.then((_) => loadExpenses());
  }

  Future<void> deleteExpense(ExpenseListItem item) async {
    await runGuarded(() async {
      final result = await _expenses.softDelete(item.expense.id);
      if (result.success) {
        ErrorHandler.showSuccess('expense_deleted'.tr);
        await loadExpenses();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
