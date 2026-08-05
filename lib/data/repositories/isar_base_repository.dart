import 'package:isar_community/isar.dart';

import '../../../core/base/base_repository.dart';
import '../../../core/errors/app_exception.dart';
import '../local/database/isar_database.dart';

/// Generic Isar CRUD helpers for typed collections.
///
/// Feature repositories extend this and add query methods. Soft-delete
/// semantics belong in feature repositories / services, not here.
abstract class IsarBaseRepository<T> extends BaseRepository {
  IsarBaseRepository(this.db);

  final IsarDatabase db;

  Isar get isar => db.isar;

  IsarCollection<T> get collection;

  Future<T?> findById(Id id) => runRead(() => collection.get(id));

  Future<List<T>> findAll() => runRead(() => collection.where().findAll());

  Future<int> count() => runRead(() => collection.count());

  Future<Id> put(T entity) => runWrite(
        () => db.writeTxn(() => collection.put(entity)),
      );

  Future<List<Id>> putAll(List<T> entities) => runWrite(
        () => db.writeTxn(() => collection.putAll(entities)),
      );

  Future<bool> deleteById(Id id) => runWrite(
        () => db.writeTxn(() => collection.delete(id)),
      );

  Future<T> getOrThrow(Id id) async {
    final entity = await findById(id);
    if (entity == null) {
      throw NotFoundException(message: 'Record not found (id=$id)');
    }
    return entity;
  }
}
