import 'package:equatable/equatable.dart';

import '../../../core/utils/app_date_utils.dart';

/// Income list filter state.
class IncomeFilter extends Equatable {
  const IncomeFilter({
    this.searchQuery = '',
    this.source,
    this.accountId,
    this.datePeriod,
    this.customRange,
  });

  final String searchQuery;
  final String? source;
  final int? accountId;
  final DatePeriod? datePeriod;
  final DateRange? customRange;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      source != null ||
      accountId != null ||
      datePeriod != null ||
      customRange != null;

  IncomeFilter copyWith({
    String? searchQuery,
    String? source,
    int? accountId,
    DatePeriod? datePeriod,
    DateRange? customRange,
    bool clearSource = false,
    bool clearAccount = false,
    bool clearDate = false,
  }) {
    return IncomeFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      source: clearSource ? null : (source ?? this.source),
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      datePeriod: clearDate ? null : (datePeriod ?? this.datePeriod),
      customRange: clearDate ? null : (customRange ?? this.customRange),
    );
  }

  static const empty = IncomeFilter();

  @override
  List<Object?> get props => [searchQuery, source, accountId, datePeriod, customRange];
}
