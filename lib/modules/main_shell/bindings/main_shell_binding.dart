import 'package:get/get.dart';

import '../../../services/auth/auth_service.dart';
import '../../../services/profile/profile_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../dashboard/bindings/dashboard_binding.dart';
import '../../expenses/bindings/expenses_binding.dart';
import '../../friends/bindings/friends_binding.dart';
import '../../income/bindings/income_binding.dart';
import '../../statistics/bindings/statistics_binding.dart';
import '../controllers/main_shell_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    DashboardBinding().dependencies();
    ExpensesBinding().dependencies();
    IncomeBinding().dependencies();
    FriendsBinding().dependencies();
    StatisticsBinding().dependencies();
    Get.lazyPut<MainShellController>(
      () => MainShellController(
        Get.find<ProfileService>(),
        Get.find<AuthService>(),
        Get.find<SettingsService>(),
      ),
    );
  }
}
