import '../errors/app_exception.dart';
import '../errors/service_result.dart';
import '../logging/app_logger.dart';

/// Mixin for application services.
///
/// Services own business logic, orchestration, and validation.
/// They call repositories / other services and return [ServiceResult].
/// They must not depend on Flutter widgets or GetX controllers.
///
/// Use with `class FooService extends GetxService with BaseService` for
/// injectable singletons, or `class FooService with BaseService` for plain
/// Dart services registered manually.
mixin BaseService {
  AppLogger get log => AppLogger.instance;

  /// Executes [action] and maps expected/unexpected errors to [ServiceResult].
  Future<ServiceResult<T>> guard<T>(
    Future<T> Function() action, {
    String fallbackMessage = 'Operation failed',
  }) async {
    try {
      final data = await action();
      return ServiceResult.success(data);
    } on AppException catch (error, stackTrace) {
      log.w(error.message, error: error, stackTrace: stackTrace);
      return ServiceResult.failure(
        userMessage: error.message,
        errorCode: error.code,
        exception: error,
      );
    } catch (error, stackTrace) {
      log.e(fallbackMessage, error: error, stackTrace: stackTrace);
      return ServiceResult.failure(
        userMessage: fallbackMessage,
        errorCode: 'UNKNOWN_ERROR',
        exception: UnknownException(
          message: error.toString(),
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Same as [guard] for void-returning work.
  Future<ServiceResult<void>> guardVoid(
    Future<void> Function() action, {
    String fallbackMessage = 'Operation failed',
  }) async {
    try {
      await action();
      return ServiceResult.success();
    } on AppException catch (error, stackTrace) {
      log.w(error.message, error: error, stackTrace: stackTrace);
      return ServiceResult.failure(
        userMessage: error.message,
        errorCode: error.code,
        exception: error,
      );
    } catch (error, stackTrace) {
      log.e(fallbackMessage, error: error, stackTrace: stackTrace);
      return ServiceResult.failure(
        userMessage: fallbackMessage,
        errorCode: 'UNKNOWN_ERROR',
        exception: UnknownException(
          message: error.toString(),
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
