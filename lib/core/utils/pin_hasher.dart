import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted PIN hashing for app lock (NFR-008).
abstract final class PinHasher {
  static const int _iterations = 10000;

  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hash(String pin, String salt) {
    var digest = sha256.convert(utf8.encode('$salt$pin')).bytes;
    for (var i = 0; i < _iterations; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return sha256.convert(digest).toString();
  }

  static bool verify(String pin, String salt, String expectedHash) =>
      hash(pin, salt) == expectedHash;
}
