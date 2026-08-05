import '../errors/app_exception.dart';
import '../logging/app_logger.dart';

/// Marker for all repositories.
///
/// Repositories own data-access concerns only (CRUD, queries, transactions).
/// They must not contain business rules or UI logic — those live in services.
abstract class BaseRepository {
  AppLogger get log => AppLogger.instance;

  /// Wraps a write so failures become typed [DbWriteException]s.
  Future<T> runWrite<T>(Future<T> Function() write) async {
    try {
      return await write();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      log.e('Repository write failed', error: error, stackTrace: stackTrace);
      throw DbWriteException(
        message: 'Failed to persist data',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Wraps a read so failures become typed [DbException]s.
  Future<T> runRead<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on AppException {
      rethrow;
    } catch (error, stackTrace) {
      log.e('Repository read failed', error: error, stackTrace: stackTrace);
      throw DbException(
        message: 'Failed to read data',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
