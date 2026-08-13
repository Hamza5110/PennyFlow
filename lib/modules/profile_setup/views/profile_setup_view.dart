import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/config/app_mode.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/profile_setup_controller.dart';

/// First-run local profile creation, followed by a one-time Simple/Full mode
/// choice (SRS §23 — no profile → create profile → pick a mode).
class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return switch (controller.step.value) {
        ProfileSetupStep.name => _NameStep(controller: controller),
        ProfileSetupStep.mode => _ModeStep(controller: controller),
      };
    });
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller});

  final ProfileSetupController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'profile_setup_title'.tr,
      subtitle: 'profile_setup_subtitle'.tr,
      automaticallyImplyLeading: false,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Icon(
              Icons.person_outline_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: controller.nameController,
              label: 'profile_setup_name_label'.tr,
              hint: 'profile_setup_name_hint'.tr,
              prefixIcon: Icons.badge_outlined,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.createProfile(),
            ),
            const SizedBox(height: 8),
            Obx(
              () {
                final error = controller.errorMessage.value;
                if (error == null) return const SizedBox.shrink();
                return Text(
                  error,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Obx(
              () => AppButton(
                label: 'profile_setup_continue'.tr,
                onPressed: controller.createProfile,
                isLoading: controller.isLoading.value,
              ),
            ),
            const Spacer(),
            Text(
              AppConstants.appTagline,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeStep extends StatelessWidget {
  const _ModeStep({required this.controller});

  final ProfileSetupController controller;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'app_mode_setup_title'.tr,
      subtitle: 'app_mode_setup_subtitle'.tr,
      automaticallyImplyLeading: false,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Obx(
              () => _AppModeCard(
                mode: AppMode.simple,
                icon: Icons.bolt_rounded,
                selected: controller.selectedMode.value == AppMode.simple,
                onTap: () => controller.selectMode(AppMode.simple),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _AppModeCard(
                mode: AppMode.full,
                icon: Icons.dashboard_customize_outlined,
                selected: controller.selectedMode.value == AppMode.full,
                onTap: () => controller.selectMode(AppMode.full),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'app_mode_setup_hint'.tr,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => AppButton(
                label: 'profile_setup_continue'.tr,
                onPressed: controller.confirmMode,
                isLoading: controller.isLoading.value,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _AppModeCard extends StatelessWidget {
  const _AppModeCard({
    required this.mode,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final AppMode mode;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.06)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.labelKey.tr,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.descriptionKey.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
