import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/config/app_mode.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../services/profile/profile_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/startup/startup_service.dart';

/// Onboarding steps shown after a fresh install: name entry, then a one-time
/// choice between Simple and Full mode (SRS §23).
enum ProfileSetupStep { name, mode }

class ProfileSetupController extends BaseController {
  ProfileSetupController(this._profiles, this._settings, this._startup);

  final ProfileService _profiles;
  final SettingsService _settings;
  final StartupService _startup;

  final nameController = TextEditingController();
  final Rx<ProfileSetupStep> step = ProfileSetupStep.name.obs;
  final Rx<AppMode> selectedMode = AppMode.simple.obs;

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> createProfile() async {
    final nameError = AppValidators.name(
      nameController.text,
      field: 'Profile name',
      maxLength: 60,
    );
    if (nameError != null) {
      errorMessage.value = nameError;
      return;
    }

    await runGuarded(() async {
      final result = await _profiles.createProfile(name: nameController.text);
      final profile = unwrapResult(result);
      if (profile == null) return;
      step.value = ProfileSetupStep.mode;
    });
  }

  void selectMode(AppMode mode) => selectedMode.value = mode;

  Future<void> confirmMode() async {
    await runGuarded(() async {
      await _settings.setAppMode(selectedMode.value);
      await _startup.navigateToInitialRoute();
    });
  }

  void goBackToName() => step.value = ProfileSetupStep.name;
}
