import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_scaffold.dart';
import 'friends_tab_view.dart';

/// Standalone Friends screen — pushed from the More list in Simple Mode
/// (and reachable as a bottom nav tab in Full Mode). Presented like Search
/// or Budgets: a normal pushed page with a back arrow, not a shell tab.
class FriendsView extends StatelessWidget {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'nav_friends'.tr,
      body: const FriendsTabView(),
    );
  }
}
