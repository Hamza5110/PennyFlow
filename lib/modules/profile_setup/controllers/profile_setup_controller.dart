import 'package:flutter/material.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/utils/validators.dart';
import '../../../services/profile/profile_service.dart';
import '../../../services/startup/startup_service.dart';

class ProfileSetupController extends BaseController {
  ProfileSetupController(this._profiles, this._startup);

  final ProfileService _profiles;
  final StartupService _startup;

  final nameController = TextEditingController();

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
      await _startup.navigateToInitialRoute();
    });
  }
}
