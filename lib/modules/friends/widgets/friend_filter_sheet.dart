import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/friend_constants.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/widgets/date_filter_section.dart';
import '../../../data/models/friend/friend_models.dart';
import '../../../services/friend/friend_service.dart';

class FriendFilterSheet extends StatefulWidget {
  const FriendFilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  final FriendFilter initial;
  final ValueChanged<FriendFilter> onApply;

  static Future<void> show({
    required FriendFilter initial,
    required ValueChanged<FriendFilter> onApply,
  }) {
    return Get.bottomSheet<void>(
      FriendFilterSheet(initial: initial, onApply: onApply),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  State<FriendFilterSheet> createState() => _FriendFilterSheetState();
}

class _FriendFilterSheetState extends State<FriendFilterSheet> {
  String? _status;
  int? _friendId;
  DatePeriod? _period;
  DateRange? _customRange;

  @override
  void initState() {
    super.initState();
    _status = widget.initial.status;
    _friendId = widget.initial.friendId;
    _period = widget.initial.datePeriod;
    _customRange = widget.initial.customRange;
  }

  @override
  Widget build(BuildContext context) {
    final friends = Get.find<FriendService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: FutureBuilder(
        future: friends.listFriends(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final friendList = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'friends_filter'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
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
                DateFilterSection(
                  initialPeriod: _period,
                  initialCustomRange: _customRange,
                  label: 'friends_date_period'.tr,
                  onChanged: (selection) {
                    setState(() {
                      _period = selection.period;
                      _customRange = selection.customRange;
                    });
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    widget.onApply(
                      widget.initial.copyWith(
                        status: _status,
                        friendId: _friendId,
                        datePeriod: _period,
                        customRange: _customRange,
                        clearStatus: _status == null,
                        clearFriend: _friendId == null,
                        clearDate: _period == null && _customRange == null,
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
