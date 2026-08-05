import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/utils/debounce.dart';
import '../../../data/models/friend/friend_models.dart';
import '../../../services/friend/friend_service.dart';
import '../../../services/search/filter_session_service.dart';
import '../friend_routes.dart';

class FriendTransactionsListController extends BaseController {
  FriendTransactionsListController(this._friends, this._session);

  final FriendService _friends;
  final FilterSessionService _session;
  final _debouncer = Debouncer();

  final RxList<FriendTransactionListItem> items =
      <FriendTransactionListItem>[].obs;
  final Rx<FriendFilter> filter = FriendFilter.empty.obs;
  final RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    filter.value = _session.friendFilter;
    searchText.value = _session.friendFilter.searchQuery;
    loadTransactions();
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }

  Future<void> loadTransactions() async {
    await runGuarded(() async {
      items.assignAll(await _friends.listTransactions(filter: filter.value));
    }, showErrorSnackbar: false);
  }

  void onSearchChanged(String value) {
    searchText.value = value;
    _debouncer.call(() {
      filter.value = filter.value.copyWith(searchQuery: value);
      _session.friendFilter = filter.value;
      loadTransactions();
    });
  }

  void applyFilter(FriendFilter next) {
    filter.value = next.copyWith(searchQuery: searchText.value);
    _session.friendFilter = filter.value;
    loadTransactions();
  }

  void clearFilters() {
    searchText.value = '';
    filter.value = FriendFilter.empty;
    _session.friendFilter = FriendFilter.empty;
    loadTransactions();
  }

  void openAdd() {
    Get.toNamed<void>(AppRoutes.friendTransactionForm)
        ?.then((_) => loadTransactions());
  }

  void openTrash() {
    Get.toNamed<void>(AppRoutes.friendTrash)?.then((_) => loadTransactions());
  }

  void openDetail(FriendTransactionListItem item) {
    Get.toNamed<void>(
      AppRoutes.friendTransactionDetail,
      arguments: FriendTransactionDetailArgs(
        transactionId: item.transaction.id,
      ),
    )?.then((_) => loadTransactions());
  }
}
