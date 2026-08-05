import 'dart:convert';

import '../../core/constants/storage_keys.dart';
import '../../data/models/auth_user.dart';
import '../storage/secure_storage_service.dart';

/// Persists Google auth session metadata in secure storage (NFR-006).
class AuthSessionStore {
  AuthSessionStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<void> save(AuthUser user) async {
    final json = jsonEncode(user.toJson());
    await _secureStorage.write(StorageKeys.googleAuthTokens, json);
  }

  Future<AuthUser?> read() async {
    final raw = await _secureStorage.read(StorageKeys.googleAuthTokens);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser.fromJson(map);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() => _secureStorage.delete(StorageKeys.googleAuthTokens);
}
