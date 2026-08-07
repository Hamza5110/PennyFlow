import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/constants/storage_keys.dart';
import 'package:penny_flow/data/models/update/release_info.dart';
import 'package:penny_flow/services/settings/settings_service.dart';
import 'package:penny_flow/services/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReleaseInfo', () {
    test('fromGitHubJson parses apk asset and version tag', () {
      final release = ReleaseInfo.fromGitHubJson(const {
        'tag_name': 'v1.2.0',
        'body': 'Bug fixes',
        'published_at': '2026-03-15T10:00:00Z',
        'assets': [
          {
            'name': 'pennyflow.apk',
            'browser_download_url': 'https://example.com/app.apk',
            'size': 1234567,
          },
        ],
      });

      expect(release.version, '1.2.0');
      expect(release.hasApk, isTrue);
      expect(release.apkFileName, 'pennyflow.apk');
      expect(release.apkSizeBytes, 1234567);
      expect(release.isForced, isFalse);
    });

    test('detects forced update from body marker', () {
      final release = ReleaseInfo.fromGitHubJson(const {
        'tag_name': '2.0.0',
        'body': 'Security patch [force-update]',
        'assets': [
          {
            'name': 'app.apk',
            'browser_download_url': 'https://example.com/app.apk',
            'size': 1,
          },
        ],
      });

      expect(release.isForced, isTrue);
    });
  });

  group('SettingsService session lock', () {
    late LocalStorageService storage;
    late SettingsService settings;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
      await storage.init();
      settings = SettingsService(storage);
      await settings.init();
      await settings.setAppLockEnabled(true);
      await settings.setLockTimeoutMinutes(5);
    });

    test('shouldLockAfterBackground is false without background timestamp', () {
      expect(settings.shouldLockAfterBackground(), isFalse);
    });

    test('shouldLockAfterBackground is true after timeout elapsed', () async {
      final past = DateTime.now().subtract(const Duration(minutes: 6));
      await storage.setString(
        StorageKeys.lastBackgroundAt,
        past.toIso8601String(),
      );

      expect(settings.shouldLockAfterBackground(), isTrue);
    });

    test('shouldLockAfterBackground is false when still within timeout', () async {
      final recent = DateTime.now().subtract(const Duration(minutes: 2));
      await storage.setString(
        StorageKeys.lastBackgroundAt,
        recent.toIso8601String(),
      );

      expect(settings.shouldLockAfterBackground(), isFalse);
    });
  });
}
