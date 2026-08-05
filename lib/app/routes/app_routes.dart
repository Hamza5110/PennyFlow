/// Route name constants. Keep paths stable — deep links / update flows depend
/// on them. Feature modules append their own routes here as they are built.
abstract final class AppRoutes {
  static const String splash = '/splash';

  // Reserved for upcoming modules (do not implement screens yet):
  static const String profileSetup = '/profile-setup';
  static const String appLock = '/app-lock';
  static const String home = '/home';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String statistics = '/statistics';
  static const String friends = '/friends';
  static const String more = '/more';
  static const String expenseForm = '/expenses/form';
  static const String expenseDetail = '/expenses/detail';
  static const String expenseTrash = '/expenses/trash';
  static const String incomeForm = '/income/form';
  static const String incomeDetail = '/income/detail';
  static const String incomeTrash = '/income/trash';
  static const String categories = '/categories';
  static const String categoryForm = '/categories/form';
  static const String accounts = '/accounts';
  static const String accountForm = '/accounts/form';
  static const String friendForm = '/friends/form';
  static const String friendDetail = '/friends/detail';
  static const String friendTransactionForm = '/friends/transactions/form';
  static const String friendTransactionDetail = '/friends/transactions/detail';
  static const String repaymentForm = '/friends/repayments/form';
  static const String friendTrash = '/friends/trash';
  static const String search = '/search';
  static const String budgets = '/budgets';
  static const String budgetForm = '/budgets/form';
  static const String reports = '/reports';
  static const String recurring = '/recurring';
  static const String recurringForm = '/recurring/form';
  static const String reminders = '/reminders';
  static const String reminderForm = '/reminders/form';
  static const String settings = '/settings';
  static const String backup = '/backup';
  static const String update = '/update';
}
