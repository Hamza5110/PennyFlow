import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/profile/profile_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../expenses/controllers/expenses_list_controller.dart';
import '../../friends/controllers/friend_transactions_list_controller.dart';
import '../../friends/controllers/friends_list_controller.dart';
import '../../income/controllers/incomes_list_controller.dart';
import '../../statistics/controllers/statistics_controller.dart';

class MainShellController extends BaseController {
  MainShellController(this._profiles, this._auth);

  final ProfileService _profiles;
  final AuthService _auth;

  final RxInt selectedIndex = 0.obs;
  final RxString profileName = ''.obs;

  AuthService get auth => _auth;

  bool get showQuickAddFab => selectedIndex.value == 0;

  @override
  void onInit() {
    super.onInit();
    _loadProfileName();
  }

  Future<void> _loadProfileName() async {
    final profile = await _profiles.getActiveProfile();
    profileName.value = profile?.name ?? 'profile_unknown'.tr;
  }

  void onTabSelected(int index) {
    selectedIndex.value = index;
    if (index == 1) {
      if (Get.isRegistered<ExpensesListController>()) {
        Get.find<ExpensesListController>().loadExpenses();
      }
      if (Get.isRegistered<IncomesListController>()) {
        Get.find<IncomesListController>().loadIncomes();
      }
    }
    if (index == 0 && Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboard();
    }
    if (index == 2 && Get.isRegistered<StatisticsController>()) {
      Get.find<StatisticsController>().loadStatistics();
    }
    if (index == 3) {
      if (Get.isRegistered<FriendsListController>()) {
        Get.find<FriendsListController>().loadFriends();
      }
      if (Get.isRegistered<FriendTransactionsListController>()) {
        Get.find<FriendTransactionsListController>().loadTransactions();
      }
    }
  }

  void openGoogleAccount() => Get.toNamed<void>(AppRoutes.auth);

  void openCategories() => Get.toNamed<void>(AppRoutes.categories);

  void openAccounts() => Get.toNamed<void>(AppRoutes.accounts);

  void openBudgets() => Get.toNamed<void>(AppRoutes.budgets);

  void openSearch() => Get.toNamed<void>(AppRoutes.search);

  void openReports() => Get.toNamed<void>(AppRoutes.reports);

  void openRecurring() => Get.toNamed<void>(AppRoutes.recurring);

  void openReminders() => Get.toNamed<void>(AppRoutes.reminders);

  void openBackup() => Get.toNamed<void>(AppRoutes.backup);

  void openSettings() => Get.toNamed<void>(AppRoutes.settings);

  Future<void> onQuickAdd() async {
    final saved = await Get.toNamed<dynamic>(AppRoutes.expenseForm);
    if (saved == true) {
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().loadDashboard();
      }
      onTabSelected(1);
    }
  }
}
