import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/debounce.dart';
import '../../../data/models/income/income_filter.dart';
import '../../../data/models/income/income_list_item.dart';
import '../../../services/income/income_service.dart';
import '../../../services/search/filter_session_service.dart';
import '../income_routes.dart';

class IncomesListController extends BaseController {
  IncomesListController(this._incomes, this._session);

  final IncomeService _incomes;
  final FilterSessionService _session;
  final _debouncer = Debouncer();

  final RxList<IncomeListItem> items = <IncomeListItem>[].obs;
  final Rx<IncomeFilter> filter = IncomeFilter.empty.obs;
  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filter.value = _session.incomeFilter;
    searchText.value = _session.incomeFilter.searchQuery;
    loadIncomes();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  Future<void> loadIncomes() async {
    await runGuarded(() async {
      items.assignAll(await _incomes.listActive(filter: filter.value));
    }, showErrorSnackbar: false);
  }

  void onSearchChanged(String value) {
    searchText.value = value;
    _debouncer.call(() {
      filter.value = filter.value.copyWith(searchQuery: value);
      _session.incomeFilter = filter.value;
      loadIncomes();
    });
  }

  void applyFilter(IncomeFilter updated) {
    filter.value = updated.copyWith(searchQuery: searchText.value);
    _session.incomeFilter = filter.value;
    loadIncomes();
  }

  void clearFilters() {
    searchText.value = '';
    filter.value = IncomeFilter.empty;
    _session.incomeFilter = IncomeFilter.empty;
    loadIncomes();
  }

  void openAdd() => Get.toNamed<void>(AppRoutes.incomeForm);

  void openDetail(IncomeListItem item) {
    Get.toNamed<void>(
      AppRoutes.incomeDetail,
      arguments: IncomeDetailArgs(incomeId: item.income.id),
    )?.then((_) => loadIncomes());
  }

  void openTrash() {
    Get.toNamed<void>(AppRoutes.incomeTrash)?.then((_) => loadIncomes());
  }

  Future<void> deleteIncome(IncomeListItem item) async {
    await runGuarded(() async {
      final result = await _incomes.softDelete(item.income.id);
      if (result.success) {
        ErrorHandler.showSuccess('income_deleted'.tr);
        await loadIncomes();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
