import 'package:get/get.dart';

import '../../../data/local/database/isar_database.dart';
import '../../../data/repositories/friend_repository.dart';
import '../../../data/repositories/friend_transaction_repository.dart';
import '../../../data/repositories/repayment_repository.dart';
import '../../../services/friend/friend_service.dart';
import '../../../services/image/image_service.dart';
import '../../../services/search/filter_session_service.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/friend_detail_controller.dart';
import '../controllers/friend_form_controller.dart';
import '../controllers/friend_transaction_detail_controller.dart';
import '../controllers/friend_transaction_form_controller.dart';
import '../controllers/friend_trash_controller.dart';
import '../controllers/friends_list_controller.dart';
import '../controllers/friend_transactions_list_controller.dart';
import '../controllers/repayment_form_controller.dart';

class FriendsBinding extends Bindings {
  @override
  void dependencies() {
    final isar = Get.find<IsarDatabase>();

    if (!Get.isRegistered<FriendRepository>()) {
      Get.put(FriendRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<FriendTransactionRepository>()) {
      Get.put(FriendTransactionRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<RepaymentRepository>()) {
      Get.put(RepaymentRepository(isar), permanent: true);
    }
    if (!Get.isRegistered<ImageService>()) {
      Get.put(ImageService(), permanent: true);
    }
    if (!Get.isRegistered<FriendService>()) {
      Get.put(
        FriendService(
          Get.find<FriendRepository>(),
          Get.find<FriendTransactionRepository>(),
          Get.find<RepaymentRepository>(),
          Get.find<ImageService>(),
          Get.find<SettingsService>(),
        ),
        permanent: true,
      );
    }

    Get.lazyPut<FriendsListController>(
      () => FriendsListController(Get.find<FriendService>()),
    );
    Get.lazyPut<FriendFormController>(
      () => FriendFormController(Get.find<FriendService>()),
    );
    Get.lazyPut<FriendDetailController>(
      () => FriendDetailController(Get.find<FriendService>()),
    );
    Get.lazyPut<FriendTransactionFormController>(
      () => FriendTransactionFormController(
        Get.find<FriendService>(),
        Get.find<ImageService>(),
      ),
    );
    Get.lazyPut<FriendTransactionDetailController>(
      () => FriendTransactionDetailController(Get.find<FriendService>()),
    );
    Get.lazyPut<FriendTransactionsListController>(
      () => FriendTransactionsListController(
        Get.find<FriendService>(),
        Get.find<FilterSessionService>(),
      ),
    );
    Get.lazyPut<RepaymentFormController>(
      () => RepaymentFormController(
        Get.find<FriendService>(),
        Get.find<ImageService>(),
      ),
    );
    Get.lazyPut<FriendTrashController>(
      () => FriendTrashController(Get.find<FriendService>()),
    );
  }
}
