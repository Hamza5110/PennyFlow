import 'package:get/get.dart';

import '../../../services/expense/expense_service.dart';
import '../../../services/friend/friend_service.dart';
import '../../../services/income/income_service.dart';
import '../../../services/search/filter_session_service.dart';
import '../../../services/search/search_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FilterSessionService>()) {
      Get.put(FilterSessionService(), permanent: true);
    }
    if (!Get.isRegistered<SearchService>()) {
      Get.put(
        SearchService(
          Get.find<ExpenseService>(),
          Get.find<IncomeService>(),
          Get.find<FriendService>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }
    Get.lazyPut<SearchController>(
      () => SearchController(
        Get.find<SearchService>(),
        Get.find<FilterSessionService>(),
      ),
    );
  }
}
