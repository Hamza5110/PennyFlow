/// Route / navigation arguments for expense screens.
class ExpenseFormArgs {
  const ExpenseFormArgs({this.expenseId});

  final int? expenseId;
}

class ExpenseDetailArgs {
  const ExpenseDetailArgs({required this.expenseId});

  final int expenseId;
}
