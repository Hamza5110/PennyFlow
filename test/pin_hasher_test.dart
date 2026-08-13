import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/core/utils/pin_hasher.dart';

void main() {
  group('PinHasher', () {
    test('verify returns true for matching PIN and salt', () {
      const pin = '1234';
      final salt = PinHasher.generateSalt();
      final hash = PinHasher.hash(pin, salt);
      expect(PinHasher.verify(pin, salt, hash), isTrue);
    });

    test('verify returns false for wrong PIN', () {
      const pin = '1234';
      final salt = PinHasher.generateSalt();
      final hash = PinHasher.hash(pin, salt);
      expect(PinHasher.verify('5678', salt, hash), isFalse);
    });

    test('different salts produce different hashes', () {
      const pin = '123456';
      final saltA = PinHasher.generateSalt();
      final saltB = PinHasher.generateSalt();
      expect(PinHasher.hash(pin, saltA), isNot(PinHasher.hash(pin, saltB)));
    });
  });
}
