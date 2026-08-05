import 'package:get/get.dart';

import '../../modules/app_lock/bindings/app_lock_binding.dart';
import '../../modules/app_lock/views/app_lock_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/auth_view.dart';
import '../../modules/expenses/bindings/expenses_binding.dart';
import '../../modules/expenses/views/expense_detail_view.dart';
import '../../modules/expenses/views/expense_form_view.dart';
import '../../modules/expenses/views/expense_trash_view.dart';
import '../../modules/accounts/bindings/accounts_binding.dart';
import '../../modules/accounts/views/account_form_view.dart';
import '../../modules/accounts/views/accounts_list_view.dart';
import '../../modules/friends/bindings/friends_binding.dart';
import '../../modules/friends/views/friend_detail_view.dart';
import '../../modules/friends/views/friend_form_view.dart';
import '../../modules/friends/views/friend_transaction_detail_view.dart';
import '../../modules/friends/views/friend_transaction_form_view.dart';
import '../../modules/friends/views/friend_trash_view.dart';
import '../../modules/friends/views/repayment_form_view.dart';
import '../../modules/categories/bindings/categories_binding.dart';
import '../../modules/categories/views/categories_list_view.dart';
import '../../modules/categories/views/category_form_view.dart';
import '../../modules/income/bindings/income_binding.dart';
import '../../modules/income/views/income_detail_view.dart';
import '../../modules/income/views/income_form_view.dart';
import '../../modules/income/views/income_trash_view.dart';
import '../../modules/main_shell/bindings/main_shell_binding.dart';
import '../../modules/main_shell/views/main_shell_page.dart';
import '../../modules/profile_setup/bindings/profile_setup_binding.dart';
import '../../modules/profile_setup/views/profile_setup_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/budgets/bindings/budgets_binding.dart';
import '../../modules/budgets/views/budget_form_view.dart';
import '../../modules/budgets/views/budgets_list_view.dart';
import '../../modules/search/bindings/search_binding.dart';
import '../../modules/search/views/search_view.dart';
import 'app_routes.dart';

/// GetX page table.
abstract final class AppPages {
  static const String initial = AppRoutes.splash;

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: SplashView.new,
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: ProfileSetupView.new,
      binding: ProfileSetupBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.appLock,
      page: AppLockView.new,
      binding: AppLockBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: MainShellPage.new,
      binding: MainShellBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.auth,
      page: AuthView.new,
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.expenseForm,
      page: ExpenseFormView.new,
      binding: ExpensesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.expenseDetail,
      page: ExpenseDetailView.new,
      binding: ExpensesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.expenseTrash,
      page: ExpenseTrashView.new,
      binding: ExpensesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.incomeForm,
      page: IncomeFormView.new,
      binding: IncomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.incomeDetail,
      page: IncomeDetailView.new,
      binding: IncomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.incomeTrash,
      page: IncomeTrashView.new,
      binding: IncomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.categories,
      page: CategoriesListView.new,
      binding: CategoriesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.categoryForm,
      page: CategoryFormView.new,
      binding: CategoriesBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.accounts,
      page: AccountsListView.new,
      binding: AccountsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.accountForm,
      page: AccountFormView.new,
      binding: AccountsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.friendForm,
      page: FriendFormView.new,
      binding: FriendsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.friendDetail,
      page: FriendDetailView.new,
      binding: FriendsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.friendTransactionForm,
      page: FriendTransactionFormView.new,
      binding: FriendsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.friendTransactionDetail,
      page: FriendTransactionDetailView.new,
      binding: FriendsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.repaymentForm,
      page: RepaymentFormView.new,
      binding: FriendsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.friendTrash,
      page: FriendTrashView.new,
      binding: FriendsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.search,
      page: SearchView.new,
      binding: SearchBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.budgets,
      page: BudgetsListView.new,
      binding: BudgetsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.budgetForm,
      page: BudgetFormView.new,
      binding: BudgetsBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
