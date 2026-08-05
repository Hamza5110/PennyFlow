import 'package:isar_community/isar.dart';

part 'app_meta.g.dart';

/// Infrastructure collection for schema versioning and DB health checks.
///
/// Not a business entity — used by [IsarDatabase] during open/migrate.
@collection
class AppMeta {
  Id id = Isar.autoIncrement;

  /// Must match [AppConstants.databaseSchemaVersion] after migrations.
  late int schemaVersion;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
