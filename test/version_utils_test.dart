import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/core/utils/version_utils.dart';

void main() {
  group('VersionUtils', () {
    test('parse handles semver with v prefix and build suffix', () {
      expect(VersionUtils.parse('v1.2.3+45'), [1, 2, 3]);
      expect(VersionUtils.parse('2.0.0-beta'), [2, 0, 0]);
    });

    test('compare orders versions correctly', () {
      expect(VersionUtils.compare('1.0.1', '1.0.0'), greaterThan(0));
      expect(VersionUtils.compare('1.0.0', '1.0.1'), lessThan(0));
      expect(VersionUtils.compare('1.2.0', '1.2.0'), 0);
    });

    test('isNewer detects newer releases', () {
      expect(VersionUtils.isNewer('1.1.0', '1.0.0'), isTrue);
      expect(VersionUtils.isNewer('1.0.0', '1.0.0'), isFalse);
      expect(VersionUtils.isNewer('0.9.9', '1.0.0'), isFalse);
    });
  });
}
