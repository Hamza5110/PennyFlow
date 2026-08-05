import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../data/models/friend/friend_models.dart';
import '../../../services/friend/friend_service.dart';
import '../friend_routes.dart';

class FriendsListController extends BaseController {
  FriendsListController(this._friends);

  final FriendService _friends;
  final RxList<FriendListItem> items = <FriendListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFriends();
  }

  Future<void> loadFriends() async {
    await runGuarded(() async {
      items.assignAll(await _friends.listFriends());
    }, showErrorSnackbar: false);
  }

  void openAddFriend() {
    Get.toNamed<void>(AppRoutes.friendForm)?.then((_) => loadFriends());
  }

  void openFriend(FriendListItem item) {
    Get.toNamed<void>(
      AppRoutes.friendDetail,
      arguments: FriendDetailArgs(friendId: item.friend.id),
    )?.then((_) => loadFriends());
  }

  void openTrash() {
    Get.toNamed<void>(AppRoutes.friendTrash)?.then((_) => loadFriends());
  }

  void openAddTransaction() {
    Get.toNamed<void>(AppRoutes.friendTransactionForm)?.then((_) => loadFriends());
  }
}
