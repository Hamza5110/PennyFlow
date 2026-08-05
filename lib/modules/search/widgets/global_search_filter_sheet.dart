import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/friend_constants.dart';
import '../../../core/utils/app_date_utils.dart';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                DropdownButtonFormField<GlobalSearchScope>(
                  initialValue: _scope,
                  decoration: InputDecoration(labelText: 'search_scope'.tr),
                  items: [
                    DropdownMenuItem(
                      value: GlobalSearchScope.all,
                      child: Text('search_scope_all'.tr),
                    ),
                    DropdownMenuItem(
                      value: GlobalSearchScope.expenses,
                      child: Text('search_scope_expenses'.tr),
                    ),
                    DropdownMenuItem(
                      value: GlobalSearchScope.income,
                      child: Text('search_scope_income'.tr),
                    ),
                    DropdownMenuItem(
                      value: GlobalSearchScope.friends,
                      child: Text('search_scope_friends'.tr),
                    ),
                  ],
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
                DropdownButtonFormField<int?>(
                  initialValue: _categoryId,
                  decoration:
                      InputDecoration(labelText: 'expense_category'.tr),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('expense_all_categories'.tr),
                    ),
                    for (final category in categoryList)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _accountId,
                  decoration: InputDecoration(labelText: 'expense_account'.tr),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('expense_all_accounts'.tr),
                    ),
                    for (final account in accountList)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                  ],
                  onChanged: (v) => setState(() => _accountId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _friendId,
                  decoration: InputDecoration(labelText: 'friends_name'.tr),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('search_all_friends'.tr),
                    ),
                    for (final item in friendList)
                      DropdownMenuItem(
                        value: item.friend.id,
                        child: Text(item.friend.name),
                      ),
                  ],
                  onChanged: (v) => setState(() => _friendId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _status,
                  decoration: InputDecoration(labelText: 'friends_status'.tr),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('friends_all_statuses'.tr),
                    ),
                    DropdownMenuItem(
                      value: FriendTransactionStatus.pending,
                      child: Text('friends_status_pending'.tr),
                    ),
                    DropdownMenuItem(
                      value: FriendTransactionStatus.partiallyPaid,
                      child: Text('friends_status_partial'.tr),
                    ),
                    DropdownMenuItem(
                      value: FriendTransactionStatus.completed,
                      child: Text('friends_status_completed'.tr),
                    ),
                  ],
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
