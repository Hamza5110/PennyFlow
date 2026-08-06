import 'package:get/get.dart';

import '../../data/models/category.dart';
import '../../data/models/payment_account.dart';
import '../category/category_service.dart';
import '../payment_account/payment_account_service.dart';
import '../settings/settings_service.dart';

/// In-memory cache for per-profile lookup maps (categories, accounts).
class ProfileLookupCacheService extends GetxService {
  ProfileLookupCacheService(this._settings);

  final SettingsService _settings;

  int? _cachedProfileId;
  Map<int, Category>? _categories;
  Map<int, PaymentAccount>? _accounts;

  Future<Map<int, Category>> categories(CategoryService service) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return {};
    if (_cachedProfileId == profileId && _categories != null) {
      return _categories!;
    }
    final list = await service.getCategories();
    _cachedProfileId = profileId;
    _categories = {for (final item in list) item.id: item};
    return _categories!;
  }

  Future<Map<int, PaymentAccount>> accounts(PaymentAccountService service) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return {};
    if (_cachedProfileId == profileId && _accounts != null) {
      return _accounts!;
    }
    final list = await service.getActiveAccounts();
    _cachedProfileId = profileId;
    _accounts = {for (final item in list) item.id: item};
    return _accounts!;
  }

  void invalidate() {
    _categories = null;
    _accounts = null;
    _cachedProfileId = null;
  }
}
