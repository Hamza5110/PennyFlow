import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/auth_controller.dart';

/// Google Sign-In screen for backup ownership (SRS §13.16).
///
/// Signing in is optional — all non-backup features work without it (FR-156).
class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'auth_title'.tr,
      body: Obx(() {
        final user = controller.currentUser.value;
        final isLoading = controller.isLoading.value;

        if (user != null) {
          return _SignedInBody(
            userEmail: user.email,
            userDisplayName: user.displayName,
            userPhotoUrl: user.photoUrl,
            userInitials: user.initials,
            isLoading: isLoading,
            onSignOut: controller.signOut,
          );
        }

        return _SignedOutBody(
          isLoading: isLoading,
          onSignIn: controller.signInWithGoogle,
          onSkip: controller.continueWithoutSigningIn,
        );
      }),
    );
  }
}

class _SignedOutBody extends StatelessWidget {
  const _SignedOutBody({
    required this.isLoading,
    required this.onSignIn,
    required this.onSkip,
  });

  final bool isLoading;
  final VoidCallback onSignIn;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.cloud_upload_outlined,
            size: 72,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'auth_signed_out_title'.tr,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'auth_signed_out_subtitle'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          AppButton(
            label: 'auth_sign_in_google'.tr,
            onPressed: onSignIn,
            isLoading: isLoading,
            icon: Icons.login_rounded,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'auth_continue_without'.tr,
            onPressed: onSkip,
            variant: AppButtonVariant.text,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _SignedInBody extends StatelessWidget {
  const _SignedInBody({
    required this.userEmail,
    required this.userDisplayName,
    required this.userPhotoUrl,
    required this.userInitials,
    required this.isLoading,
    required this.onSignOut,
  });

  final String userEmail;
  final String? userDisplayName;
  final String? userPhotoUrl;
  final String userInitials;
  final bool isLoading;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage:
                  userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
              child: userPhotoUrl == null
                  ? Text(
                      userInitials,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'auth_signed_in_title'.tr,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (userDisplayName != null && userDisplayName!.isNotEmpty)
            Text(
              userDisplayName!,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          Text(
            userEmail,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'auth_signed_in_subtitle'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          AppButton(
            label: 'auth_sign_out'.tr,
            onPressed: onSignOut,
            isLoading: isLoading,
            variant: AppButtonVariant.outlined,
            icon: Icons.logout_rounded,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'common_ok'.tr,
            onPressed: () => Get.back<void>(),
            variant: AppButtonVariant.text,
            expand: true,
          ),
        ],
      ),
    );
  }
}
