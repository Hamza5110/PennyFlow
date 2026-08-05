import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/logging/app_logger.dart';

/// Keystore-backed secure storage for tokens, PIN hashes, and secrets (NFR-006).
///
/// Never store secrets in SharedPreferences.
class SecureStorageService extends GetxService with BaseService {
  late final FlutterSecureStorage _storage;

  Future<SecureStorageService> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    AppLogger.instance.i('SecureStorage ready');
    return this;
  }

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }
}
