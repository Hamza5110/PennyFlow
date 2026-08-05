import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/profile_setup_controller.dart';

/// First-run local profile creation (SRS §23 — no profile → create profile).
class ProfileSetupView extends GetView<ProfileSetupController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      showAppBar: false,
      isLoading: false,
      body: SafeArea(
        child: Padding(
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
              Text(
                'profile_setup_title'.tr,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'profile_setup_subtitle'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
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
      ),
    );
  }
}
