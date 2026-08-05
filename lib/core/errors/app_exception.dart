import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../logging/app_logger.dart';

/// Base typed exception for PennyFlow.
///
/// Prefer throwing subclasses so callers can branch on type rather than
/// string-matching messages.
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.cause,
    this.stackTrace,
  });

  final String message;
  final String? code;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      '$runtimeType(${code != null ? '$code: ' : ''}$message)';
}

final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.field,
    super.cause,
    super.stackTrace,
  });

  final String? field;
}

final class DbException extends AppException {
  const DbException({
    required super.message,
    super.code = 'DB_ERROR',
    super.cause,
    super.stackTrace,
  });
}

final class DbWriteException extends DbException {
  const DbWriteException({
    required super.message,
    super.code = 'DB_WRITE_ERROR',
    super.cause,
    super.stackTrace,
  });
}

final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = 'NETWORK_ERROR',
    super.cause,
    super.stackTrace,
  });
}

final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.cause,
    super.stackTrace,
  });
}

final class BackupException extends AppException {
  const BackupException({
    required super.message,
    super.code = 'BACKUP_ERROR',
    super.cause,
    super.stackTrace,
  });
}

final class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND',
    super.cause,
    super.stackTrace,
  });
}

final class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code = 'UNKNOWN_ERROR',
    super.cause,
    super.stackTrace,
  });
}

/// Immutable failure value for non-throwing error channels (e.g. Either-style).
class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
    this.exception,
  });

  factory Failure.fromException(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return Failure(
        message: error.message,
        code: error.code,
        exception: error,
      );
    }
    AppLogger.instance.e(
      'Unhandled exception',
      error: error,
      stackTrace: stackTrace,
    );
    return Failure(
      message: 'Something went wrong',
      code: 'UNKNOWN_ERROR',
      exception: UnknownException(
        message: error.toString(),
        cause: error,
        stackTrace: stackTrace,
      ),
    );
  }

  final String message;
  final String? code;
  final AppException? exception;

  @override
  List<Object?> get props => [message, code];
}

/// Maps [Level] for logger filter configuration.
extension FailureLogLevel on Failure {
  Level get logLevel {
    switch (code) {
      case 'VALIDATION_ERROR':
        return Level.warning;
      case 'NETWORK_ERROR':
        return Level.warning;
      default:
        return Level.error;
    }
  }
}
