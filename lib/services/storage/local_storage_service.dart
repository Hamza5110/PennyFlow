import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/base/base_service.dart';
import '../../core/errors/app_exception.dart';

/// Thin wrapper over SharedPreferences for lightweight settings (SRS §11).
///
/// Do not store transactional data or secrets here — use Isar / secure storage.
class LocalStorageService extends GetxService with BaseService {
  SharedPreferences? _prefs;

  SharedPreferences get prefs {
    final value = _prefs;
    if (value == null) {
      throw const DbException(
        message: 'Local storage has not been initialized',
        code: 'STORAGE_NOT_READY',
      );
    }
    return value;
  }

  Future<LocalStorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    log.i('SharedPreferences ready');
    return this;
  }

  Future<bool> setString(String key, String value) =>
      prefs.setString(key, value);

  String? getString(String key) => prefs.getString(key);

  Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);

  bool? getBool(String key) => prefs.getBool(key);

  bool getBoolOr(String key, bool fallback) => prefs.getBool(key) ?? fallback;

  Future<bool> setInt(String key, int value) => prefs.setInt(key, value);

  int? getInt(String key) => prefs.getInt(key);

  int getIntOr(String key, int fallback) => prefs.getInt(key) ?? fallback;

  Future<bool> setDouble(String key, double value) =>
      prefs.setDouble(key, value);

  double? getDouble(String key) => prefs.getDouble(key);

  Future<bool> remove(String key) => prefs.remove(key);

  Future<bool> clear() => prefs.clear();

  bool containsKey(String key) => prefs.containsKey(key);
}
