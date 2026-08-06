import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/utils/pin_hasher.dart';
import 'package:penny_flow/core/utils/version_utils.dart';
import 'package:penny_flow/data/models/update/release_info.dart';

/// Critical-path smoke checks for release confidence.
void main() {
  group('Regression suite', () {
    test('PIN hashing verifies matching digits', () {
      const pin = '1234';
      final salt = PinHasher.generateSalt();
      final hash = PinHasher.hash(pin, salt);
      expect(PinHasher.verify(pin, salt, hash), isTrue);
      expect(PinHasher.verify('0000', salt, hash), isFalse);
    });

    test('version comparison treats semver correctly', () {
      expect(VersionUtils.compare('1.2.0', '1.1.9'), greaterThan(0));
      expect(VersionUtils.compare('1.0.0', '1.0.0'), 0);
      expect(VersionUtils.compare('0.9.9', '1.0.0'), lessThan(0));
    });

    test('release info parses minimum viable GitHub payload', () {
      final release = ReleaseInfo.fromGitHubJson({
        'tag_name': 'v3.0.0',
        'body': 'Release notes',
        'assets': [
          {
            'name': 'pennyflow.apk',
            'browser_download_url': 'https://example.com/app.apk',
            'size': 100,
          },
        ],
      });

      expect(release.version, '3.0.0');
      expect(release.hasApk, isTrue);
    });
  });
}
