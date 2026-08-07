import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/friend/friend_models.dart';
import '../../../data/models/repayment.dart';
import '../../../services/friend/friend_service.dart';
import '../friend_routes.dart';

class FriendTransactionDetailController extends BaseController {
  FriendTransactionDetailController(this._friends);

  final FriendService _friends;

  final Rxn<FriendTransactionListItem> item = Rxn<FriendTransactionListItem>();
  final RxList<Repayment> repayments = <Repayment>[].obs;
  int? _transactionId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FriendTransactionDetailArgs) {
      _transactionId = args.transactionId;
      load();
    }
  }

  Future<void> load() async {
    final id = _transactionId;
    if (id == null) return;

    await runGuarded(() async {
      final txn = await _friends.getTransactionById(id);
      if (txn == null) {
        ErrorHandler.showError('friends_transaction_not_found'.tr);
        Get.back<void>();
        return;
      }
      final remaining = await _friends.remainingBalance(id);
      final items = await _friends.listTransactions(friendId: txn.friendId);
      item.value = items.firstWhere(
        (e) => e.transaction.id == id,
        orElse: () => FriendTransactionListItem(
          transaction: txn,
          friendName: 'Unknown',
          remainingBalance: remaining,
          repaymentTotal: txn.amount - remaining,
        ),
      );
      repayments.assignAll(await _friends.getRepayments(id));
    }, showErrorSnackbar: false);
  }

  void edit() {
    final id = _transactionId;
    if (id == null) return;
    Get.toNamed<void>(
      AppRoutes.friendTransactionForm,
      arguments: FriendTransactionFormArgs(transactionId: id),
    )?.then((_) => load());
  }

  void addRepayment() {
    final id = _transactionId;
    if (id == null) return;
    Get.toNamed<void>(
      AppRoutes.repaymentForm,
      arguments: RepaymentFormArgs(transactionId: id),
    )?.then((_) => load());
  }

  Future<void> delete() async {
    final id = _transactionId;
    if (id == null) return;
    await runGuarded(() async {
      final result = await _friends.softDeleteTransaction(id);
      if (result.success) {
        ErrorHandler.popWithSuccess('friends_transaction_deleted'.tr);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
