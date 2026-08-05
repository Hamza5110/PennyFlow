import 'package:equatable/equatable.dart';

import '../../../core/utils/app_date_utils.dart';

/// Expense list filter state (FR-023).
class ExpenseFilter extends Equatable {
  const ExpenseFilter({
    this.searchQuery = '',
    this.categoryId,
    this.accountId,
    this.datePeriod,
    this.customRange,
    this.tag,
  });

  final String searchQuery;
  final int? categoryId;
  final int? accountId;
  final DatePeriod? datePeriod;
  final DateRange? customRange;
  final String? tag;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      categoryId != null ||
      accountId != null ||
      datePeriod != null ||
      customRange != null ||
      (tag != null && tag!.isNotEmpty);

  ExpenseFilter copyWith({
    String? searchQuery,
    int? categoryId,
    int? accountId,
    DatePeriod? datePeriod,
    DateRange? customRange,
    String? tag,
    bool clearCategory = false,
    bool clearAccount = false,
    bool clearDate = false,
    bool clearTag = false,
  }) {
    return ExpenseFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      datePeriod: clearDate ? null : (datePeriod ?? this.datePeriod),
      customRange: clearDate ? null : (customRange ?? this.customRange),
      tag: clearTag ? null : (tag ?? this.tag),
    );
  }

  static const empty = ExpenseFilter();

  @override
  List<Object?> get props => [
        searchQuery,
        categoryId,
        accountId,
        datePeriod,
        customRange,
        tag,
      ];
}
