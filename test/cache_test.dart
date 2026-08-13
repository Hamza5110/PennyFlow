import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_vault/data/models/category.dart';
import 'package:spend_vault/data/repositories/category_repository.dart';
import 'package:spend_vault/data/repositories/expense_repository.dart';
import 'package:spend_vault/services/cache/profile_lookup_cache_service.dart';
import 'package:spend_vault/services/category/category_service.dart';
import 'package:spend_vault/services/settings/settings_service.dart';
import 'package:spend_vault/services/storage/local_storage_service.dart';

import 'support/isar_test_helper.dart';

void main() {
  late TestIsarHarness harness;
  late SettingsService settings;
  late ProfileLookupCacheService cache;
  late CategoryService categories;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    harness = await TestIsarHarness.open();

    final localStorage = LocalStorageService();
    await localStorage.init();
    settings = SettingsService(localStorage);
    await settings.init();
    await settings.setActiveProfileId(1);

    categories = CategoryService(
      CategoryRepository(harness.db),
      ExpenseRepository(harness.db),
      settings,
    );
    await categories.init();

    cache = ProfileLookupCacheService(settings);
  });

  tearDown(() async {
    Get.reset();
    await harness.dispose();
  });

  group('ProfileLookupCacheService', () {
    test('caches categories until invalidated', () async {
      final first = await cache.categories(categories);
      expect(first, isNotEmpty);

      await CategoryRepository(harness.db).put(
        Category()
          ..name = 'Fuel'
          ..colorHex = '#EAB308'
          ..iconKey = 'local_gas_station'
          ..profileId = 1,
      );

      final stillCached = await cache.categories(categories);
      expect(stillCached.length, first.length);

      cache.invalidate();
      final refreshed = await cache.categories(categories);
      expect(refreshed.length, greaterThan(first.length));
    });
  });
}
