/// Route / navigation arguments for income screens.
class IncomeFormArgs {
  const IncomeFormArgs({this.incomeId});

  final int? incomeId;
}

class IncomeDetailArgs {
  const IncomeDetailArgs({required this.incomeId});

  final int incomeId;
}
