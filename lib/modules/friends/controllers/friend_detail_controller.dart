import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/constants/friend_constants.dart';
import '../../../data/models/friend/friend_models.dart';
import '../../../services/friend/friend_service.dart';
import '../friend_routes.dart';

class FriendDetailController extends BaseController {
  FriendDetailController(this._friends);

  final FriendService _friends;

  final Rxn<FriendListItem> friendItem = Rxn<FriendListItem>();
  final RxList<FriendTransactionListItem> transactions =
      <FriendTransactionListItem>[].obs;
  int? _friendId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FriendDetailArgs) {
      _friendId = args.friendId;
      load();
    }
  }

  Future<void> load() async {
    final id = _friendId;
    if (id == null) return;
    await runGuarded(() async {
      final friends = await _friends.listFriends();
      friendItem.value = friends.firstWhere(
        (f) => f.friend.id == id,
        orElse: () => throw Exception('not found'),
      );
      transactions.assignAll(
        await _friends.listTransactions(friendId: id),
      );
    }, showErrorSnackbar: false);
  }

  void editFriend() {
    final id = _friendId;
    if (id == null) return;
    Get.toNamed<void>(
      AppRoutes.friendForm,
      arguments: FriendFormArgs(friendId: id),
    )?.then((_) => load());
  }

  void addGiven() => _openTransactionForm(FriendTransactionTypes.given);

  void addReceived() => _openTransactionForm(FriendTransactionTypes.received);

  void _openTransactionForm(String type) {
    final id = _friendId;
    if (id == null) return;
    Get.toNamed<void>(
      AppRoutes.friendTransactionForm,
      arguments: FriendTransactionFormArgs(friendId: id, type: type),
    )?.then((_) => load());
  }

  void openTransaction(FriendTransactionListItem item) {
    Get.toNamed<void>(
      AppRoutes.friendTransactionDetail,
      arguments: FriendTransactionDetailArgs(
        transactionId: item.transaction.id,
      ),
    )?.then((_) => load());
  }
}
