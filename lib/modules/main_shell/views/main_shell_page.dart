import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../friends/views/friends_tab_view.dart';
import '../../statistics/views/statistics_tab_view.dart';
import '../../transactions/views/transactions_tab_view.dart';
import '../controllers/main_shell_controller.dart';
import 'main_shell_view.dart';

class MainShellPage extends GetView<MainShellController> {
  const MainShellPage({super.key});

  /// Metadata for every [ShellTabIndex], regardless of app mode. The bottom
  /// nav bar only renders the subset in [MainShellController.visibleTabIndices].
  static const _allTabs = <_ShellTab>[
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
      final tab = _allTabs[index];
      final visibleIndices = controller.visibleTabIndices;
      final theme = Theme.of(context);

      final selectedPosition = visibleIndices.indexOf(index);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tab.labelKey.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (index == ShellTabIndex.dashboard)
                Obx(
                  () => Text(
                    controller.profileName.value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (index == ShellTabIndex.more)
                Obx(
                  () => Text(
                    'more_greeting'.trParams({
                      'name': controller.profileName.value,
                    }),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          actions: [
            if (index == ShellTabIndex.dashboard)
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'settings_title'.tr,
                onPressed: controller.openSettings,
              ),
            if (index == ShellTabIndex.more)
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'search_title'.tr,
                onPressed: controller.openSearch,
              ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        body: IndexedStack(
          index: index,
          children: const [
            DashboardView(),
            TransactionsTabView(),
            StatisticsTabView(),
            FriendsTabView(),
            MoreTabView(),
          ],
        ),
        floatingActionButton: controller.showQuickAddFab
            ? FloatingActionButton.extended(
                heroTag: 'main_shell_quick_add',
                onPressed: controller.onQuickAdd,
                icon: const Icon(Icons.add_rounded),
                label: Text('dashboard_quick_add'.tr),
              )
            : null,
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: selectedPosition,
          onSelected: (position) =>
              controller.onTabSelected(visibleIndices[position]),
          items: [
            for (final viewIndex in visibleIndices)
              AppBottomNavItem(
                label: _allTabs[viewIndex].labelKey.tr,
                icon: _allTabs[viewIndex].icon,
                selectedIcon: _allTabs[viewIndex].selectedIcon,
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
