import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:spend_vault/data/local/database/isar_database.dart';
import 'package:spend_vault/data/local/database/isar_schemas.dart';

/// Opens an isolated Isar database for repository tests.
class TestIsarHarness {
  TestIsarHarness(this.db, this.isar, this._directory);

  static bool _coreInitialized = false;

  final IsarDatabase db;
  final Isar isar;
  final Directory _directory;

  static Future<TestIsarHarness> open() async {
    if (!_coreInitialized) {
      await Isar.initializeIsarCore(download: true);
      _coreInitialized = true;
    }

    final directory = await Directory.systemTemp.createTemp('spend_vault_test_');
    final isar = await Isar.open(
      IsarSchemas.all,
      directory: directory.path,
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    final db = IsarDatabase();
    await db.bindIsarForTesting(isar);
    return TestIsarHarness(db, isar, directory);
  }

  Future<void> dispose() async {
    if (isar.isOpen) {
      await isar.close(deleteFromDisk: true);
    }
    if (await _directory.exists()) {
      await _directory.delete(recursive: true);
    }
  }
}
