import 'package:equatable/equatable.dart';

import '../income.dart';

/// Income row enriched with account label and display source for list UI.
class IncomeListItem extends Equatable {
  const IncomeListItem({
    required this.income,
    required this.sourceLabel,
    required this.sourceColorHex,
    required this.accountName,
  });

  final Income income;
  final String sourceLabel;
  final String sourceColorHex;
  final String accountName;

  @override
  List<Object?> get props => [income, sourceLabel, sourceColorHex, accountName];
}
