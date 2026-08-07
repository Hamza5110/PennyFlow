import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/extensions/string_extensions.dart';
import '../../core/utils/category_icons.dart';
import '../../data/models/category.dart';
import '../../data/models/category/category_input.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../cache/profile_lookup_cache_service.dart';
import '../settings/settings_service.dart';

/// Default expense categories (FR-063).
abstract final class CategoryDefaults {
  static const List<({String name, String colorHex, String iconKey})> items = [
    (name: 'Food', colorHex: '#F97316', iconKey: 'restaurant'),
    (name: 'Fuel', colorHex: '#EAB308', iconKey: 'local_gas_station'),
    (name: 'Shopping', colorHex: '#EC4899', iconKey: 'shopping_bag'),
    (name: 'Rent', colorHex: '#8B5CF6', iconKey: 'home'),
    (name: 'Bills', colorHex: '#3B82F6', iconKey: 'receipt_long'),
    (name: 'Entertainment', colorHex: '#A855F7', iconKey: 'movie'),
    (name: 'Grocery', colorHex: '#22C55E', iconKey: 'shopping_cart'),
    (name: 'Medical', colorHex: '#EF4444', iconKey: 'medical_services'),
    (name: 'Education', colorHex: '#0EA5E9', iconKey: 'school'),
    (name: 'Investment', colorHex: '#14B8A6', iconKey: 'trending_up'),
    (name: 'Family', colorHex: '#F43F5E', iconKey: 'family_restroom'),
    (name: 'Other', colorHex: '#64748B', iconKey: 'more_horiz'),
  ];
}

class CategoryService extends GetxService with BaseService {
  CategoryService(this._repository, this._expenses, this._settings);

  final CategoryRepository _repository;
  final ExpenseRepository _expenses;
  final SettingsService _settings;

  Future<CategoryService> init() async {
    await _ensureDefaults();
    return this;
  }

  int? get _profileId => _settings.activeProfileId;

  Future<void> _ensureDefaults() async {
    final profileId = _profileId;
    if (profileId == null) return;

    final count = await _repository.countByProfile(profileId);
    if (count > 0) return;

    await _seedDefaults(profileId);
    log.i('Seeded default categories for profile $profileId');
  }

  Future<void> ensureDefaultsForProfile(int profileId) async {
    final count = await _repository.countByProfile(profileId);
    if (count > 0) return;
    await _seedDefaults(profileId);
  }

  Future<void> _seedDefaults(int profileId) async {
    await _repository.db.writeTxn(() async {
      for (final item in CategoryDefaults.items) {
        final category = Category()
          ..name = item.name
          ..colorHex = item.colorHex
          ..iconKey = item.iconKey
          ..isDefault = true
          ..profileId = profileId;
        await _repository.collection.put(category);
      }
    });
  }

  Future<List<Category>> getCategories() async {
    final profileId = _profileId;
    if (profileId == null) return [];
    await _ensureDefaults();
    return _repository.findByProfile(profileId);
  }

  Future<Category?> getById(int id) => _repository.findById(id);

  Future<int> countUsage(int categoryId) async {
    final profileId = _profileId;
    if (profileId == null) return 0;
    return _expenses.countActiveByCategory(categoryId, profileId);
  }

  Future<ServiceResult<Category>> create(CategoryInput input) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateInput(input);
      await _ensureUniqueName(profileId, input.name);

      final category = Category()
        ..name = input.name.trim()
        ..colorHex = input.colorHex
        ..iconKey = input.iconKey
        ..isDefault = false
        ..profileId = profileId;

      final id = await _repository.put(category);
      category.id = id;
      _invalidateLookupCache();
      return category;
    });
  }

  Future<ServiceResult<Category>> update(int id, CategoryInput input) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateInput(input);
      final existing = await _getOwnedCategory(id, profileId);
      await _ensureUniqueName(profileId, input.name, excludeId: id);

      existing
        ..name = input.name.trim()
        ..colorHex = input.colorHex
        ..iconKey = input.iconKey;

      await _repository.put(existing);
      _invalidateLookupCache();
      return existing;
    });
  }

  Future<ServiceResult<void>> delete(
    int id, {
    int? reassignToCategoryId,
  }) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final category = await _getOwnedCategory(id, profileId);

      if (category.isDefault) {
        throw const ValidationException(
          message: 'Default categories cannot be deleted',
          code: 'CATEGORY_DEFAULT',
          field: 'category',
        );
      }

      final usage = await _expenses.countActiveByCategory(id, profileId);
      if (usage > 0) {
        if (reassignToCategoryId == null) {
          throw ValidationException(
            message:
                'Category is used by $usage expense(s). Choose another category to reassign them.',
            code: 'CATEGORY_IN_USE',
            field: 'category',
          );
        }
        if (reassignToCategoryId == id) {
          throw const ValidationException(
            message: 'Choose a different category for reassignment',
            field: 'reassignToCategoryId',
          );
        }
        final target = await _getOwnedCategory(reassignToCategoryId, profileId);
        if (target.id == id) {
          throw const ValidationException(
            message: 'Choose a different category for reassignment',
            field: 'reassignToCategoryId',
          );
        }
        await _expenses.reassignCategory(
          fromCategoryId: id,
          toCategoryId: reassignToCategoryId,
          profileId: profileId,
        );
      }

      await _repository.deleteById(id);
      _invalidateLookupCache();
    });
  }

  void _invalidateLookupCache() {
    if (Get.isRegistered<ProfileLookupCacheService>()) {
      Get.find<ProfileLookupCacheService>().invalidate();
    }
  }

  void _validateInput(CategoryInput input) {
    final name = input.name.trim();
    if (name.isBlank) {
      throw const ValidationException(message: 'Name is required', field: 'name');
    }
    if (name.length > ValidationConstants.maxCategoryNameLength) {
      throw const ValidationException(
        message:
            'Name must be at most ${ValidationConstants.maxCategoryNameLength} characters',
        field: 'name',
      );
    }
    if (!CategoryIcons.colorPalette.contains(input.colorHex)) {
      throw const ValidationException(
        message: 'Select a valid color',
        field: 'colorHex',
      );
    }
    if (!CategoryIcons.availableKeys.contains(input.iconKey)) {
      throw const ValidationException(
        message: 'Select a valid icon',
        field: 'iconKey',
      );
    }
  }

  Future<void> _ensureUniqueName(
    int profileId,
    String name, {
    int? excludeId,
  }) async {
    final existing = await _repository.findByName(profileId, name.trim());
    if (existing != null && existing.id != excludeId) {
      throw const ValidationException(
        message: 'A category with this name already exists',
        code: 'CATEGORY_NAME_EXISTS',
        field: 'name',
      );
    }
  }

  int _requireProfileId() {
    final id = _profileId;
    if (id == null) {
      throw const NotFoundException(
        message: 'No active profile',
        code: 'PROFILE_NOT_FOUND',
      );
    }
    return id;
  }

  Future<Category> _getOwnedCategory(int id, int profileId) async {
    final category = await _repository.getOrThrow(id);
    if (category.profileId != profileId) {
      throw const NotFoundException(message: 'Category not found');
    }
    return category;
  }
}
