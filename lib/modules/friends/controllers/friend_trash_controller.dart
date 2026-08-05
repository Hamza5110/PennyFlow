import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/friend/friend_models.dart';
import '../../../services/friend/friend_service.dart';

class FriendTrashController extends BaseController {
  FriendTrashController(this._friends);

  final FriendService _friends;

  final RxList<FriendTransactionListItem> items = <FriendTransactionListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrash();
  }

  Future<void> loadTrash() async {
    await runGuarded(() async {
      items.assignAll(await _friends.listTrash());
    }, showErrorSnackbar: false);
  }

  Future<void> restore(FriendTransactionListItem item) async {
    await runGuarded(() async {
      final result = await _friends.restoreTransaction(item.transaction.id);
      if (result.success) {
        ErrorHandler.showSuccess('friends_transaction_restored'.tr);
        await loadTrash();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> deletePermanently(FriendTransactionListItem item) async {
    await runGuarded(() async {
      final result =
          await _friends.permanentDeleteTransaction(item.transaction.id);
      if (result.success) {
        ErrorHandler.showSuccess('friends_transaction_purged'.tr);
        await loadTrash();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
