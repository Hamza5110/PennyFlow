import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'friend_transactions_list_view.dart';
import 'friends_list_view.dart';

class FriendsTabView extends StatelessWidget {
  const FriendsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              tabs: [
                Tab(text: 'friends_tab_friends'.tr),
                Tab(text: 'friends_tab_transactions'.tr),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                FriendsListView(),
                FriendTransactionsListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
