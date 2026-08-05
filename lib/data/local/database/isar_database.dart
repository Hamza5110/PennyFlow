import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../../models/app_meta.dart';
import 'isar_schemas.dart';

/// Owns the single Isar instance for the app.
///
/// Access via `Get.find<IsarDatabase>().isar` or the [isar] getter after
/// [InitialBinding] has registered this service.
class IsarDatabase extends GetxService {
  Isar? _isar;

  Isar get isar {
    final instance = _isar;
    if (instance == null) {
      throw const DbException(
        message: 'Database has not been initialized',
        code: 'DB_NOT_READY',
      );
    }
    return instance;
  }

  bool get isOpen => _isar != null && _isar!.isOpen;

  Future<IsarDatabase> init() async {
    if (_isar != null && _isar!.isOpen) return this;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        IsarSchemas.all,
        directory: dir.path,
        name: 'penny_flow',
        inspector: true,
      );
      await _ensureMeta();
      AppLogger.instance.i(
        'Isar opened at ${dir.path} (schema v${AppConstants.databaseSchemaVersion})',
      );
      return this;
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Failed to open Isar',
        error: error,
        stackTrace: stackTrace,
      );
      throw DbException(
        message: 'Could not open local database',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _ensureMeta() async {
    final existing = await isar.appMetas.where().findFirst();
    if (existing != null) {
      if (existing.schemaVersion < AppConstants.databaseSchemaVersion) {
        await _migrate(existing.schemaVersion);
      }
      return;
    }

    await isar.writeTxn(() async {
      final meta = AppMeta()
        ..schemaVersion = AppConstants.databaseSchemaVersion
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await isar.appMetas.put(meta);
    });
  }

  /// Placeholder migration hook — expand as collections are added.
  Future<void> _migrate(int fromVersion) async {
    AppLogger.instance.i(
      'Migrating database from v$fromVersion → v${AppConstants.databaseSchemaVersion}',
    );
    await isar.writeTxn(() async {
      final meta = await isar.appMetas.where().findFirst();
      if (meta != null) {
        meta
          ..schemaVersion = AppConstants.databaseSchemaVersion
          ..updatedAt = DateTime.now();
        await isar.appMetas.put(meta);
      }
    });
  }

  /// Runs [action] inside a write transaction.
  Future<T> writeTxn<T>(Future<T> Function() action) =>
      isar.writeTxn(action);

  Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  @override
  void onClose() {
    close();
    super.onClose();
  }
}
