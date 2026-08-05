import 'package:equatable/equatable.dart';

import '../expense.dart';

/// Expense row enriched with category/account labels for list UI.
class ExpenseListItem extends Equatable {
  const ExpenseListItem({
    required this.expense,
    required this.categoryName,
    required this.categoryColorHex,
    required this.accountName,
  });

  final Expense expense;
  final String categoryName;
  final String categoryColorHex;
  final String accountName;

  @override
  List<Object?> get props =>
      [expense, categoryName, categoryColorHex, accountName];
}
