import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboard/views/dashboard_view.dart';
import '../../transactions/views/transactions_tab_view.dart';
import '../../friends/views/friends_tab_view.dart';
import '../../statistics/views/statistics_tab_view.dart';
import '../controllers/main_shell_controller.dart';
import '../views/main_shell_view.dart';

class MainShellPage extends GetView<MainShellController> {
  const MainShellPage({super.key});

  static const _tabs = <_ShellTab>[
    _ShellTab(
      labelKey: 'nav_dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _ShellTab(
      labelKey: 'nav_transactions',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _ShellTab(
      labelKey: 'nav_statistics',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
    _ShellTab(
      labelKey: 'nav_friends',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
    ),
    _ShellTab(
      labelKey: 'nav_more',
      icon: Icons.more_horiz_rounded,
      selectedIcon: Icons.more_horiz_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedIndex.value;

      return Scaffold(
        body: IndexedStack(
          index: index,
          children: [
            DashboardView(),
            TransactionsTabView(),
            const StatisticsTabView(),
            const FriendsTabView(),
            MoreTabView(),
          ],
        ),
        floatingActionButton: controller.showQuickAddFab
            ? FloatingActionButton.extended(
                onPressed: controller.onQuickAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text('dashboard_quick_add'.tr),
              )
            : null,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: controller.onTabSelected,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.labelKey.tr,
              ),
          ],
        ),
      );
    });
  }
}

class _ShellTab {
  const _ShellTab({
    required this.labelKey,
    required this.icon,
    required this.selectedIcon,
  });

  final String labelKey;
  final IconData icon;
  final IconData selectedIcon;
}
