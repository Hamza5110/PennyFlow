import 'package:equatable/equatable.dart';

import 'app_exception.dart';

/// Standard service-layer result envelope (SRS §26.1).
///
/// Services return [ServiceResult] instead of throwing for expected failures
/// (validation, not-found, network). Unexpected errors may still throw and
/// should be caught by [ErrorHandler].
class ServiceResult<T> extends Equatable {
  const ServiceResult._({
    required this.success,
    this.data,
    this.errorCode,
    this.userMessage,
    this.exception,
  });

  factory ServiceResult.success([T? data]) => ServiceResult._(
        success: true,
        data: data,
      );

  factory ServiceResult.failure({
    required String userMessage,
    String? errorCode,
    AppException? exception,
  }) =>
      ServiceResult._(
        success: false,
        userMessage: userMessage,
        errorCode: errorCode ?? exception?.code,
        exception: exception,
      );

  factory ServiceResult.cancelled({String errorCode = 'CANCELLED'}) =>
      ServiceResult._(
        success: false,
        errorCode: errorCode,
      );

  factory ServiceResult.fromFailure(Failure failure) => ServiceResult.failure(
        userMessage: failure.message,
        errorCode: failure.code,
        exception: failure.exception,
      );

  final bool success;
  final T? data;
  final String? errorCode;
  final String? userMessage;
  final AppException? exception;

  bool get isFailure => !success;

  /// Transforms [data] when successful; preserves failure as-is.
  ServiceResult<R> map<R>(R Function(T data) transform) {
    if (success && data != null) {
      return ServiceResult.success(transform(data as T));
    }
    if (success && data == null) {
      return ServiceResult.success();
    }
    return ServiceResult.failure(
      userMessage: userMessage ?? 'Unknown error',
      errorCode: errorCode,
      exception: exception,
    );
  }

  @override
  List<Object?> get props => [success, data, errorCode, userMessage];
}
