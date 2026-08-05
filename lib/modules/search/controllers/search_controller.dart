import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/utils/debounce.dart';
import '../../../data/models/search/global_search_filter.dart';
import '../../../data/models/search/global_search_result.dart';
import '../../../modules/expenses/expense_routes.dart';
import '../../../modules/friends/friend_routes.dart';
import '../../../modules/income/income_routes.dart';
import '../../../services/search/filter_session_service.dart';
import '../../../services/search/search_service.dart';

class SearchController extends BaseController {
  SearchController(this._search, this._session);

  final SearchService _search;
  final FilterSessionService _session;
  final _debouncer = Debouncer();

  final Rx<GlobalSearchFilter> filter = GlobalSearchFilter.empty.obs;
  final RxList<GlobalSearchResult> results = <GlobalSearchResult>[].obs;
  final RxString searchText = ''.obs;
  final searchFieldController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    filter.value = _session.globalSearchFilter;
    searchText.value = _session.globalSearchFilter.searchQuery;
    searchFieldController.text = searchText.value;
    if (filter.value.searchQuery.isNotEmpty) {
      runSearch();
    }
  }

  @override
  void onClose() {
    _debouncer.dispose();
    searchFieldController.dispose();
    super.onClose();
  }

  Future<void> runSearch() async {
    await runGuarded(() async {
      results.assignAll(await _search.search(filter.value));
    }, showErrorSnackbar: false);
  }

  void onSearchChanged(String value) {
    searchText.value = value;
    _debouncer.call(() {
      filter.value = filter.value.copyWith(searchQuery: value);
      _session.globalSearchFilter = filter.value;
      runSearch();
    });
  }

  void applyFilter(GlobalSearchFilter updated) {
    filter.value = updated.copyWith(searchQuery: searchText.value);
    _session.globalSearchFilter = filter.value;
    runSearch();
  }

  void clearFilters() {
    searchText.value = '';
    searchFieldController.clear();
    filter.value = GlobalSearchFilter.empty;
    _session.globalSearchFilter = GlobalSearchFilter.empty;
    results.clear();
  }

  void openResult(GlobalSearchResult result) {
    switch (result.type) {
      case GlobalSearchResultType.expense:
        Get.toNamed<void>(
          AppRoutes.expenseDetail,
          arguments: ExpenseDetailArgs(expenseId: result.recordId),
        )?.then((_) => runSearch());
      case GlobalSearchResultType.income:
        Get.toNamed<void>(
          AppRoutes.incomeDetail,
          arguments: IncomeDetailArgs(incomeId: result.recordId),
        )?.then((_) => runSearch());
      case GlobalSearchResultType.friendTransaction:
        Get.toNamed<void>(
          AppRoutes.friendTransactionDetail,
          arguments: FriendTransactionDetailArgs(
            transactionId: result.recordId,
          ),
        )?.then((_) => runSearch());
    }
  }
}
