import 'package:get/get.dart';

import '../../../app/config/app_mode.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/profile/profile_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../dashboard/widgets/quick_add_sheet.dart';
import '../../expenses/controllers/expenses_list_controller.dart';
import '../../friends/controllers/friend_transactions_list_controller.dart';
import '../../friends/controllers/friends_list_controller.dart';
import '../../income/controllers/incomes_list_controller.dart';
import '../../statistics/controllers/statistics_controller.dart';
import '../../update/widgets/update_prompt_dialog.dart';

/// Indices into the main shell's [IndexedStack], stable across app modes.
abstract final class ShellTabIndex {
  static const int dashboard = 0;
  static const int transactions = 1;
  static const int statistics = 2;
  static const int friends = 3;
  static const int more = 4;
}

class MainShellController extends BaseController {
  MainShellController(this._profiles, this._auth, this._settings);

  final ProfileService _profiles;
  final AuthService _auth;
  final SettingsService _settings;

  final RxInt selectedIndex = 0.obs;
  final RxString profileName = ''.obs;

  AuthService get auth => _auth;

  Rx<AppMode> get appMode => _settings.appMode;

  bool get isSimpleMode => appMode.value == AppMode.simple;

  bool get showQuickAddFab => selectedIndex.value == ShellTabIndex.dashboard;

  /// Underlying [ShellTabIndex] values shown as bottom nav tabs for the
  /// current mode. Statistics/Friends move into the More list in Simple
  /// Mode but remain reachable — see [MoreTabView].
  List<int> get visibleTabIndices => isSimpleMode
      ? const [
          ShellTabIndex.dashboard,
          ShellTabIndex.transactions,
          ShellTabIndex.more,
        ]
      : const [
          ShellTabIndex.dashboard,
          ShellTabIndex.transactions,
          ShellTabIndex.statistics,
          ShellTabIndex.friends,
          ShellTabIndex.more,
        ];

  @override
  void onInit() {
    super.onInit();
    _loadProfileName();
    _maybePromptForUpdate();
  }

  Future<void> _maybePromptForUpdate() async {
    await UpdatePromptDialog.showIfNeeded();
  }

  Future<void> _loadProfileName() async {
    final profile = await _profiles.getActiveProfile();
    profileName.value = profile?.name ?? 'profile_unknown'.tr;
  }

  void onTabSelected(int index) {
    selectedIndex.value = index;
    if (index == ShellTabIndex.transactions) {
      if (Get.isRegistered<ExpensesListController>()) {
        Get.find<ExpensesListController>().loadExpenses();
      }
      if (Get.isRegistered<IncomesListController>()) {
        Get.find<IncomesListController>().loadIncomes();
      }
    }
    if (index == ShellTabIndex.dashboard &&
        Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboard();
    }
    if (index == ShellTabIndex.statistics &&
        Get.isRegistered<StatisticsController>()) {
      Get.find<StatisticsController>().loadStatistics();
    }
    if (index == ShellTabIndex.friends) {
      if (Get.isRegistered<FriendsListController>()) {
        Get.find<FriendsListController>().loadFriends();
      }
      if (Get.isRegistered<FriendTransactionsListController>()) {
        Get.find<FriendTransactionsListController>().loadTransactions();
      }
    }
  }

  /// Used by the More list in Simple Mode: pushes Statistics as a standalone
  /// page (like Search/Budgets), not a shell tab switch.
  void openStatistics() => Get.toNamed<void>(AppRoutes.statistics);

  void openFriends() => Get.toNamed<void>(AppRoutes.friends);

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
    final saved = isSimpleMode
        ? await QuickAddSheet.show()
        : await Get.toNamed<dynamic>(AppRoutes.expenseForm) == true;

    if (saved) {
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().loadDashboard();
      }
      onTabSelected(ShellTabIndex.transactions);
    }
  }
}
