import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/utils/backup_checksum_utils.dart';
import 'package:penny_flow/data/models/backup/backup_manifest.dart';

void main() {
  group('BackupChecksumUtils', () {
    test('sha256OfBytes is stable', () {
      final hash = BackupChecksumUtils.sha256OfBytes([1, 2, 3]);
      expect(hash, isNotEmpty);
      expect(
        BackupChecksumUtils.verifySha256([1, 2, 3], hash),
        isTrue,
      );
    });
  });

  group('BackupManifest', () {
    test('round-trips through JSON', () {
      final manifest = BackupManifest(
        formatVersion: 1,
        schemaVersion: 9,
        profileId: 3,
        createdAt: DateTime.utc(2026, 3, 15, 12),
        sha256: 'abc123',
        bundleBytes: 1024,
        profileName: 'Test',
      );

      final restored = BackupManifest.fromJson(manifest.toJson());
      expect(restored.profileId, 3);
      expect(restored.sha256, 'abc123');
      expect(restored.profileName, 'Test');
    });
  });
}
