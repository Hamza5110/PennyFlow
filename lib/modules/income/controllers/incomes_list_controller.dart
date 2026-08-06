import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/constants/app_constants.dart';
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
  final scrollController = ScrollController();

  final RxList<IncomeListItem> items = <IncomeListItem>[].obs;
  final Rx<IncomeFilter> filter = IncomeFilter.empty.obs;
  final RxString searchText = ''.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  int _offset = 0;

  @override
  void onInit() {
    super.onInit();
    filter.value = _session.incomeFilter;
    searchText.value = _session.incomeFilter.searchQuery;
    scrollController.addListener(_onScroll);
    loadIncomes();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) return;
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      loadMore();
    }
  }

  Future<void> loadIncomes() async {
    await runGuarded(() async {
      _offset = 0;
      hasMore.value = true;
      final page = await _incomes.listActivePaged(
        filter: filter.value,
        offset: 0,
        limit: AppConstants.listPageSize,
      );
      items.assignAll(page.items);
      hasMore.value = page.hasMore;
      _offset = page.items.length;
    }, showErrorSnackbar: false);
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final page = await _incomes.listActivePaged(
        filter: filter.value,
        offset: _offset,
        limit: AppConstants.listPageSize,
      );
      items.addAll(page.items);
      hasMore.value = page.hasMore;
      _offset += page.items.length;
    } finally {
      isLoadingMore.value = false;
    }
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
