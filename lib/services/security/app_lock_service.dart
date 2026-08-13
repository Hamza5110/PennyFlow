import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/utils/pin_hasher.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/profile_repository.dart';
import '../settings/settings_service.dart';
import '../storage/secure_storage_service.dart';

/// PIN and biometric app lock orchestration (SRS §13.17, FR-161–FR-164).
class AppLockService extends GetxService with BaseService {
  AppLockService(
    this._settings,
    this._secure,
    this._profiles,
  );

  final SettingsService _settings;
  final SecureStorageService _secure;
  final ProfileRepository _profiles;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> hasPinConfigured() =>
      _secure.containsKey(StorageKeys.pinHash);

  Future<ServiceResult<void>> setupPin(String pin) async {
    return guardVoid(() async {
      final error = AppValidators.pin(pin);
      if (error != null) {
        throw ValidationException(message: error, field: 'pin');
      }

      final salt = PinHasher.generateSalt();
      final hash = PinHasher.hash(pin, salt);
      await _secure.write(StorageKeys.pinSalt, salt);
      await _secure.write(StorageKeys.pinHash, hash);
      await _syncProfilePinHash(hash);
    });
  }

  Future<ServiceResult<void>> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    return guardVoid(() async {
      final valid = await verifyPin(currentPin);
      if (!valid) {
        throw const SecurityException(
          message: 'Current PIN is incorrect',
          code: 'PIN_INVALID',
        );
      }
      final result = await setupPin(newPin);
      if (!result.success) {
        throw SecurityException(
          message: result.userMessage ?? 'Could not change PIN',
          code: result.errorCode,
        );
      }
    });
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _secure.read(StorageKeys.pinSalt);
    final hash = await _secure.read(StorageKeys.pinHash);
    if (salt == null || hash == null) return false;
    return PinHasher.verify(pin, salt, hash);
  }

  Future<ServiceResult<void>> removePin({required String currentPin}) async {
    return guardVoid(() async {
      final valid = await verifyPin(currentPin);
      if (!valid) {
        throw const SecurityException(
          message: 'PIN is incorrect',
          code: 'PIN_INVALID',
        );
      }
      await _secure.delete(StorageKeys.pinHash);
      await _secure.delete(StorageKeys.pinSalt);
      await _syncProfilePinHash(null);
      await _settings.setBiometricEnabled(false);
    });
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  Future<ServiceResult<void>> authenticateWithBiometric() async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        return ServiceResult.failure(
          userMessage: 'Biometric authentication is not available',
          errorCode: 'BIOMETRIC_UNAVAILABLE',
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock SpendVault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          sensitiveTransaction: false,
        ),
      );

      if (!authenticated) {
        return ServiceResult.cancelled(errorCode: 'BIOMETRIC_CANCELLED');
      }

      return ServiceResult.success();
    } on PlatformException catch (error) {
      return _biometricPlatformFailure(error);
    } catch (error, stackTrace) {
      log.e('Biometric authentication failed', error: error, stackTrace: stackTrace);
      return ServiceResult.failure(
        userMessage: 'Biometric authentication failed',
        errorCode: 'BIOMETRIC_FAILED',
      );
    }
  }

  ServiceResult<void> _biometricPlatformFailure(PlatformException error) {
    switch (error.code) {
      case auth_error.notAvailable:
      case auth_error.notEnrolled:
      case auth_error.passcodeNotSet:
        return ServiceResult.failure(
          userMessage: 'Biometric authentication is not available',
          errorCode: 'BIOMETRIC_UNAVAILABLE',
        );
      case auth_error.lockedOut:
      case auth_error.permanentlyLockedOut:
        return ServiceResult.failure(
          userMessage: 'Biometric authentication is temporarily locked',
          errorCode: error.code,
        );
      default:
        return ServiceResult.cancelled(errorCode: 'BIOMETRIC_CANCELLED');
    }
  }

  Future<ServiceResult<void>> enableAppLock({required String pin}) async {
    return guardVoid(() async {
      final setup = await setupPin(pin);
      if (!setup.success) {
        throw SecurityException(
          message: setup.userMessage ?? 'Could not set PIN',
          code: setup.errorCode,
        );
      }
      await _settings.setAppLockEnabled(true);
      await _syncProfileAppLockEnabled(true);
      _settings.lockSession();
    });
  }

  Future<ServiceResult<void>> disableAppLock({required String pin}) async {
    return guardVoid(() async {
      final valid = await verifyPin(pin);
      if (!valid) {
        throw const SecurityException(
          message: 'PIN is incorrect',
          code: 'PIN_INVALID',
        );
      }
      await _settings.setAppLockEnabled(false);
      await _settings.setBiometricEnabled(false);
      await _syncProfileAppLockEnabled(false);
      await _secure.delete(StorageKeys.pinHash);
      await _secure.delete(StorageKeys.pinSalt);
      await _syncProfilePinHash(null);
      _settings.unlockSession();
    });
  }

  Future<ServiceResult<void>> unlockWithPin(String pin) async {
    return guardVoid(() async {
      final valid = await verifyPin(pin);
      if (!valid) {
        throw const SecurityException(
          message: 'Incorrect PIN',
          code: 'PIN_INVALID',
        );
      }
      _settings.unlockSession();
    });
  }

  Future<ServiceResult<void>> unlockWithBiometric() async {
    final result = await authenticateWithBiometric();
    if (result.success) {
      _settings.unlockSession();
    }
    return result;
  }

  Future<void> _syncProfilePinHash(String? hash) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return;
    final profile = await _profiles.findById(profileId);
    if (profile == null) return;
    profile.pinHash = hash;
    await _profiles.put(profile);
  }

  Future<void> _syncProfileAppLockEnabled(bool enabled) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return;
    final profile = await _profiles.findById(profileId);
    if (profile == null) return;
    profile.appLockEnabled = enabled;
    await _profiles.put(profile);
  }

  Future<void> syncBiometricToProfile(bool enabled) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return;
    final profile = await _profiles.findById(profileId);
    if (profile == null) return;
    profile.biometricEnabled = enabled;
    await _profiles.put(profile);
  }
}
