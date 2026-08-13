/// Route / navigation arguments for expense screens.
class ExpenseFormArgs {
  const ExpenseFormArgs({this.expenseId, this.prefillAmount});

  final int? expenseId;

  /// Carries over an amount already typed in the Quick Add sheet when the
  /// user asks for "More details" instead of saving directly.
  final double? prefillAmount;
}

class ExpenseDetailArgs {
  const ExpenseDetailArgs({required this.expenseId});

  final int expenseId;
}
