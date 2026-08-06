import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/validation_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../services/security/app_lock_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/startup/startup_service.dart';

class AppLockController extends BaseController {
  AppLockController(this._startup, this._appLock, this._settings);

  final StartupService _startup;
  final AppLockService _appLock;
  final SettingsService _settings;

  final RxString pinBuffer = ''.obs;
  final RxBool hasError = false.obs;
  final RxBool biometricAvailable = false.obs;
  final RxBool showBiometric = false.obs;

  bool _biometricInProgress = false;
  bool _autoPromptAttempted = false;
  bool _userDeclinedBiometric = false;

  int get targetPinLength => ValidationConstants.minPinLength;

  @override
  void onInit() {
    super.onInit();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    biometricAvailable.value = await _appLock.isBiometricAvailable();
    showBiometric.value =
        biometricAvailable.value && _settings.biometricEnabled.value;

    if (!showBiometric.value || _autoPromptAttempted || _userDeclinedBiometric) {
      return;
    }

    _autoPromptAttempted = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!isClosed) {
          unlockWithBiometric(autoPrompt: true);
        }
      });
    });
  }

  void onDigit(String digit) {
    if (pinBuffer.value.length >= ValidationConstants.maxPinLength) return;
    hasError.value = false;
    pinBuffer.value += digit;

    if (pinBuffer.value.length == ValidationConstants.minPinLength ||
        pinBuffer.value.length == ValidationConstants.maxPinLength) {
      _verifyPin();
    }
  }

  void onBackspace() {
    if (pinBuffer.isEmpty) return;
    hasError.value = false;
    pinBuffer.value = pinBuffer.value.substring(0, pinBuffer.value.length - 1);
  }

  Future<void> _verifyPin() async {
    final pin = pinBuffer.value;
    if (pin.length != ValidationConstants.minPinLength &&
        pin.length != ValidationConstants.maxPinLength) {
      return;
    }

    await runGuarded(() async {
      final result = await _appLock.unlockWithPin(pin);
      if (!result.success) {
        hasError.value = true;
        pinBuffer.value = '';
        if (result.userMessage != null) {
          ErrorHandler.showError(result.userMessage!);
        }
        return;
      }
      await _startup.navigateAfterUnlock();
    }, trackLoading: false);
  }

  Future<void> unlockWithBiometric({bool autoPrompt = false}) async {
    if (_biometricInProgress) return;
    _biometricInProgress = true;
    try {
      await runGuarded(() async {
        final result = await _appLock.unlockWithBiometric();
        if (!result.success) {
          if (autoPrompt && result.errorCode == 'BIOMETRIC_CANCELLED') {
            _userDeclinedBiometric = true;
          }
          return;
        }
        await _startup.navigateAfterUnlock();
      }, trackLoading: false);
    } finally {
      _biometricInProgress = false;
    }
  }
}
