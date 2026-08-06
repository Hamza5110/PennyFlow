import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/friend_constants.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/date_filter_section.dart';
import '../../../data/models/category.dart';
import '../../../data/models/friend/friend_models.dart';
import '../../../data/models/payment_account.dart';
import '../../../data/models/search/global_search_filter.dart';
import '../../../services/category/category_service.dart';
import '../../../services/friend/friend_service.dart';
import '../../../services/payment_account/payment_account_service.dart';

class GlobalSearchFilterSheet extends StatefulWidget {
  const GlobalSearchFilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  final GlobalSearchFilter initial;
  final ValueChanged<GlobalSearchFilter> onApply;

  static Future<void> show({
    required GlobalSearchFilter initial,
    required ValueChanged<GlobalSearchFilter> onApply,
  }) {
    return Get.bottomSheet<void>(
      GlobalSearchFilterSheet(initial: initial, onApply: onApply),
      isScrollControlled: true,
      backgroundColor: AppBottomSheet.backgroundColorFromTheme,
      shape: AppBottomSheet.shape,
    );
  }

  @override
  State<GlobalSearchFilterSheet> createState() =>
      _GlobalSearchFilterSheetState();
}

class _GlobalSearchFilterSheetState extends State<GlobalSearchFilterSheet> {
  late GlobalSearchScope _scope;
  late int? _categoryId;
  late int? _accountId;
  late int? _friendId;
  late String? _status;
  DatePeriod? _period;
  DateRange? _customRange;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scope = widget.initial.scope;
    _categoryId = widget.initial.categoryId;
    _accountId = widget.initial.accountId;
    _friendId = widget.initial.friendId;
    _status = widget.initial.friendStatus;
    _period = widget.initial.datePeriod;
    _customRange = widget.initial.customRange;
    _tagController.text = widget.initial.tag ?? '';
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = Get.find<CategoryService>();
    final accounts = Get.find<PaymentAccountService>();
    final friends = Get.find<FriendService>();

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: FutureBuilder(
        future: Future.wait([
          categories.getCategories(),
          accounts.getActiveAccounts(),
          friends.listFriends(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final categoryList = snapshot.data![0] as List<Category>;
          final accountList = snapshot.data![1] as List<PaymentAccount>;
          final friendList = snapshot.data![2] as List<FriendListItem>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'search_advanced_filters'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                AppDropdown<GlobalSearchScope>(
                  items: const [
                    GlobalSearchScope.all,
                    GlobalSearchScope.expenses,
                    GlobalSearchScope.income,
                    GlobalSearchScope.friends,
                  ],
                  itemLabel: (scope) => switch (scope) {
                    GlobalSearchScope.all => 'search_scope_all'.tr,
                    GlobalSearchScope.expenses => 'search_scope_expenses'.tr,
                    GlobalSearchScope.income => 'search_scope_income'.tr,
                    GlobalSearchScope.friends => 'search_scope_friends'.tr,
                  },
                  value: _scope,
                  label: 'search_scope'.tr,
                  onChanged: (v) => setState(() => _scope = v ?? _scope),
                ),
                const SizedBox(height: 12),
                DateFilterSection(
                  initialPeriod: _period,
                  initialCustomRange: _customRange,
                  onChanged: (selection) {
                    setState(() {
                      _period = selection.period;
                      _customRange = selection.customRange;
                    });
                  },
                ),
                const SizedBox(height: 12),
                AppDropdown<int?>(
                  items: [null, ...categoryList.map((c) => c.id)],
                  itemLabel: (id) {
                    if (id == null) return 'expense_all_categories'.tr;
                    return categoryList.firstWhere((c) => c.id == id).name;
                  },
                  value: _categoryId,
                  label: 'expense_category'.tr,
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 12),
                AppDropdown<int?>(
                  items: [null, ...accountList.map((a) => a.id)],
                  itemLabel: (id) {
                    if (id == null) return 'expense_all_accounts'.tr;
                    return accountList.firstWhere((a) => a.id == id).name;
                  },
                  value: _accountId,
                  label: 'expense_account'.tr,
                  onChanged: (v) => setState(() => _accountId = v),
                ),
                const SizedBox(height: 12),
                AppDropdown<int?>(
                  items: [null, ...friendList.map((item) => item.friend.id)],
                  itemLabel: (id) {
                    if (id == null) return 'search_all_friends'.tr;
                    return friendList
                        .firstWhere((item) => item.friend.id == id)
                        .friend
                        .name;
                  },
                  value: _friendId,
                  label: 'friends_name'.tr,
                  onChanged: (v) => setState(() => _friendId = v),
                ),
                const SizedBox(height: 12),
                AppDropdown<String?>(
                  items: const [
                    null,
                    FriendTransactionStatus.pending,
                    FriendTransactionStatus.partiallyPaid,
                    FriendTransactionStatus.completed,
                  ],
                  itemLabel: (status) => switch (status) {
                    null => 'friends_all_statuses'.tr,
                    FriendTransactionStatus.pending =>
                      'friends_status_pending'.tr,
                    FriendTransactionStatus.partiallyPaid =>
                      'friends_status_partial'.tr,
                    FriendTransactionStatus.completed =>
                      'friends_status_completed'.tr,
                    _ => '',
                  },
                  value: _status,
                  label: 'friends_status'.tr,
                  onChanged: (v) => setState(() => _status = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagController,
                  decoration: InputDecoration(labelText: 'expense_tags'.tr),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    widget.onApply(
                      widget.initial.copyWith(
                        scope: _scope,
                        categoryId: _categoryId,
                        accountId: _accountId,
                        friendId: _friendId,
                        friendStatus: _status,
                        datePeriod: _period,
                        customRange: _customRange,
                        tag: _tagController.text.trim().isEmpty
                            ? null
                            : _tagController.text.trim(),
                        clearCategory: _categoryId == null,
                        clearAccount: _accountId == null,
                        clearFriend: _friendId == null,
                        clearStatus: _status == null,
                        clearDate: _period == null,
                        clearTag: _tagController.text.trim().isEmpty,
                      ),
                    );
                    Get.back<void>();
                  },
                  child: Text('expense_apply_filters'.tr),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
