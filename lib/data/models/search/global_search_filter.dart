import 'package:equatable/equatable.dart';

import '../../../core/utils/app_date_utils.dart';

/// Scope for global search results.
enum GlobalSearchScope {
  all,
  expenses,
  income,
  friends,
}

/// Combined filter for global search and advanced filters (FR-105–FR-107).
class GlobalSearchFilter extends Equatable {
  const GlobalSearchFilter({
    this.searchQuery = '',
    this.scope = GlobalSearchScope.all,
    this.datePeriod,
    this.customRange,
    this.categoryId,
    this.accountId,
    this.friendId,
    this.friendStatus,
    this.tag,
  });

  final String searchQuery;
  final GlobalSearchScope scope;
  final DatePeriod? datePeriod;
  final DateRange? customRange;
  final int? categoryId;
  final int? accountId;
  final int? friendId;
  final String? friendStatus;
  final String? tag;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      scope != GlobalSearchScope.all ||
      datePeriod != null ||
      customRange != null ||
      categoryId != null ||
      accountId != null ||
      friendId != null ||
      friendStatus != null ||
      (tag != null && tag!.isNotEmpty);

  GlobalSearchFilter copyWith({
    String? searchQuery,
    GlobalSearchScope? scope,
    DatePeriod? datePeriod,
    DateRange? customRange,
    int? categoryId,
    int? accountId,
    int? friendId,
    String? friendStatus,
    String? tag,
    bool clearDate = false,
    bool clearCategory = false,
    bool clearAccount = false,
    bool clearFriend = false,
    bool clearStatus = false,
    bool clearTag = false,
  }) {
    return GlobalSearchFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      scope: scope ?? this.scope,
      datePeriod: clearDate ? null : (datePeriod ?? this.datePeriod),
      customRange: clearDate ? null : (customRange ?? this.customRange),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      friendId: clearFriend ? null : (friendId ?? this.friendId),
      friendStatus: clearStatus ? null : (friendStatus ?? this.friendStatus),
      tag: clearTag ? null : (tag ?? this.tag),
    );
  }

  static const empty = GlobalSearchFilter();

  @override
  List<Object?> get props => [
        searchQuery,
        scope,
        datePeriod,
        customRange,
        categoryId,
        accountId,
        friendId,
        friendStatus,
        tag,
      ];
}
