import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/extensions/string_extensions.dart';
import '../../data/models/profile.dart';
import '../../data/repositories/profile_repository.dart';
import '../category/category_service.dart';
import '../payment_account/payment_account_service.dart';
import '../settings/settings_service.dart';

/// Local profile lifecycle for startup routing (SRS §9).
class ProfileService extends GetxService with BaseService {
  ProfileService(
    this._repository,
    this._settings,
    this._categories,
    this._accounts,
  );

  final ProfileRepository _repository;
  final SettingsService _settings;
  final CategoryService _categories;
  final PaymentAccountService _accounts;

  Future<ProfileService> init() async {
    await _ensureActiveProfile();
    return this;
  }

  Future<bool> hasAnyProfile() async {
    final count = await _repository.countProfiles();
    return count > 0;
  }

  Future<Profile?> getActiveProfile() async {
    final id = _settings.activeProfileId;
    if (id == null) return null;
    return _repository.findById(id);
  }

  /// Links the active local profile to a Google account (FR-155).
  Future<ServiceResult<Profile>> linkGoogleAccount({
    required String email,
  }) async {
    return guard(() async {
      final profile = await getActiveProfile();
      if (profile == null) {
        throw const NotFoundException(
          message: 'No active profile found',
          code: 'PROFILE_NOT_FOUND',
        );
      }
      profile.googleAccountEmail = email.trim();
      await _repository.put(profile);
      log.i('Linked Google account to profile id=${profile.id}');
      return profile;
    });
  }

  /// Clears Google account link from the active profile (FR-157).
  Future<ServiceResult<Profile>> unlinkGoogleAccount() async {
    return guard(() async {
      final profile = await getActiveProfile();
      if (profile == null) {
        throw const NotFoundException(
          message: 'No active profile found',
          code: 'PROFILE_NOT_FOUND',
        );
      }
      profile.googleAccountEmail = null;
      await _repository.put(profile);
      log.i('Unlinked Google account from profile id=${profile.id}');
      return profile;
    });
  }

  Future<ServiceResult<Profile>> createProfile({required String name}) async {
    return guard(() async {
      final trimmed = name.trim();
      final nameError = _validateName(trimmed);
      if (nameError != null) {
        throw ValidationException(message: nameError, field: 'name');
      }

      final profile = Profile()
        ..name = trimmed
        ..currencyCode = _settings.currencyCode.value
        ..createdAt = DateTime.now();

      final id = await _repository.put(profile);
      profile.id = id;

      await _settings.setActiveProfileId(id);
      await _settings.setOnboardingCompleted();
      await _categories.ensureDefaultsForProfile(id);
      await _accounts.ensureDefaultsForProfile(id);

      log.i('Profile created: id=$id name=$trimmed');
      return profile;
    });
  }

  Future<void> updateActiveProfileCurrency(String code) async {
    final profile = await getActiveProfile();
    if (profile == null) return;
    profile.currencyCode = code.toUpperCase();
    await _repository.put(profile);
  }

  Future<void> _ensureActiveProfile() async {
    if (_settings.activeProfileId != null) return;

    final first = await _repository.findFirst();
    if (first != null) {
      await _settings.setActiveProfileId(first.id);
      await _settings.setOnboardingCompleted();
      log.i('Restored active profile id=${first.id}');
    }
  }

  String? _validateName(String name) {
    if (name.isBlank) return 'Name is required';
    if (name.length > ValidationConstants.maxFriendNameLength) {
      return 'Name must be at most ${ValidationConstants.maxFriendNameLength} characters';
    }
    return null;
  }
}
