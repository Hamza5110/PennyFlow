import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/friend_constants.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/search_match_utils.dart';
import '../../data/models/expense/expense_filter.dart';
import '../../data/models/friend/friend_models.dart';
import '../../data/models/income/income_filter.dart';
import '../../data/models/search/global_search_filter.dart';
import '../../data/models/search/global_search_result.dart';
import '../expense/expense_service.dart';
import '../friend/friend_service.dart';
import '../income/income_service.dart';
import '../settings/settings_service.dart';

/// Global search across expenses, income, and friend transactions (FR-099).
class SearchService extends GetxService with BaseService {
  SearchService(
    this._expenses,
    this._income,
    this._friends,
    this._settings,
  );

  final ExpenseService _expenses;
  final IncomeService _income;
  final FriendService _friends;
  final SettingsService _settings;

  Future<List<GlobalSearchResult>> search(GlobalSearchFilter filter) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];

    final results = <GlobalSearchResult>[];
    final scope = filter.scope;

    if (scope == GlobalSearchScope.all || scope == GlobalSearchScope.expenses) {
      results.addAll(await _searchExpenses(filter));
    }
    if (scope == GlobalSearchScope.all || scope == GlobalSearchScope.income) {
      results.addAll(await _searchIncome(filter));
    }
    if (scope == GlobalSearchScope.all || scope == GlobalSearchScope.friends) {
      results.addAll(await _searchFriendTransactions(filter));
    }

    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  Future<List<GlobalSearchResult>> _searchExpenses(
    GlobalSearchFilter filter,
  ) async {
    final expenseFilter = ExpenseFilter(
      searchQuery: filter.searchQuery,
      categoryId: filter.categoryId,
      accountId: filter.accountId,
      datePeriod: filter.datePeriod,
      customRange: filter.customRange,
      tag: filter.tag,
    );
    final items = await _expenses.listActive(filter: expenseFilter);
    return items
        .map(
          (item) => GlobalSearchResult(
            type: GlobalSearchResultType.expense,
            recordId: item.expense.id,
            title: item.expense.notes?.isNotEmpty == true
                ? item.expense.notes!
                : item.categoryName,
            subtitle: '${item.categoryName} · ${item.accountName}',
            amount: item.expense.amount,
            date: item.expense.date,
            colorHex: item.categoryColorHex,
          ),
        )
        .toList();
  }

  Future<List<GlobalSearchResult>> _searchIncome(
    GlobalSearchFilter filter,
  ) async {
    if (filter.categoryId != null ||
        filter.friendId != null ||
        filter.friendStatus != null ||
        (filter.tag != null && filter.tag!.isNotEmpty)) {
      return [];
    }

    final incomeFilter = IncomeFilter(
      searchQuery: filter.searchQuery,
      accountId: filter.accountId,
      datePeriod: filter.datePeriod,
      customRange: filter.customRange,
    );
    final items = await _income.listActive(filter: incomeFilter);
    return items
        .map(
          (item) => GlobalSearchResult(
            type: GlobalSearchResultType.income,
            recordId: item.income.id,
            title: item.income.notes?.isNotEmpty == true
                ? item.income.notes!
                : item.sourceLabel,
            subtitle: '${item.sourceLabel} · ${item.accountName}',
            amount: item.income.amount,
            date: item.income.date,
            colorHex: item.sourceColorHex,
          ),
        )
        .toList();
  }

  Future<List<GlobalSearchResult>> _searchFriendTransactions(
    GlobalSearchFilter filter,
  ) async {
    if (filter.categoryId != null ||
        (filter.tag != null && filter.tag!.isNotEmpty)) {
      return [];
    }

    final friendFilter = FriendFilter(
      searchQuery: filter.searchQuery,
      status: filter.friendStatus,
      datePeriod: filter.datePeriod,
      customRange: filter.customRange,
      friendId: filter.friendId,
    );
    final items = await _friends.listTransactions(filter: friendFilter);
    return items
        .map(
          (item) => GlobalSearchResult(
            type: GlobalSearchResultType.friendTransaction,
            recordId: item.transaction.id,
            title: item.friendName,
            subtitle: item.transaction.type == FriendTransactionTypes.given
                ? 'friends_money_given'.tr
                : 'friends_money_received'.tr,
            amount: item.transaction.amount,
            date: item.transaction.date,
          ),
        )
        .toList();
  }

  /// Applies date range from a generic filter helper.
  static DateRange? resolveDateRange({
    DatePeriod? period,
    DateRange? customRange,
  }) {
    if (customRange != null) return customRange;
    if (period == null) return null;
    if (period == DatePeriod.custom) return customRange;
    return AppDateUtils.rangeFor(period);
  }

  /// Field search used by list services (FR-100).
  static bool queryMatches({
    required String query,
    required List<String> fields,
    DateTime? date,
  }) =>
      SearchMatchUtils.matches(query, fields, date: date);
}
