import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../controllers/main_shell_controller.dart';

class MoreTabView extends GetView<MainShellController> {
  const MoreTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Obx(
          () => Text(
            'more_greeting'.trParams({'name': controller.profileName.value}),
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.appTagline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final user = controller.auth.currentUser.value;
              final isSignedIn = user != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'home_google_account'.tr,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSignedIn
                        ? 'home_google_signed_in'.trParams({
                            'email': user.email,
                          })
                        : 'home_google_signed_out'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: isSignedIn
                        ? 'home_manage_google'.tr
                        : 'home_sign_in_google'.tr,
                    onPressed: controller.openGoogleAccount,
                    variant: isSignedIn
                        ? AppButtonVariant.outlined
                        : AppButtonVariant.filled,
                    icon: Icons.login_rounded,
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.search_rounded),
            title: Text('search_title'.tr),
            subtitle: Text('more_search_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: controller.openSearch,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.pie_chart_outline_rounded),
            title: Text('budgets_title'.tr),
            subtitle: Text('more_budgets_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: controller.openBudgets,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.summarize_outlined),
            title: Text('reports_title'.tr),
            subtitle: Text('more_reports_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: controller.openReports,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text('categories_title'.tr),
            subtitle: Text('more_categories_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: controller.openCategories,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text('accounts_title'.tr),
            subtitle: Text('more_accounts_subtitle'.tr),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: controller.openAccounts,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text('more_about'.tr),
            subtitle: const Text('PennyFlow v1.0.0'),
          ),
        ),
      ],
    );
  }
}

class PlaceholderTabView extends StatelessWidget {
  const PlaceholderTabView({
    super.key,
    required this.titleKey,
    required this.messageKey,
    required this.icon,
  });

  final String titleKey;
  final String messageKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: titleKey.tr,
      message: messageKey.tr,
      icon: icon,
    );
  }
}
