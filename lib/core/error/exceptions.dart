/// Base class for all exceptions in the application.
/// Exceptions represent unexpected error states that may require logging.
abstract class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  final String message;
  final int? code;
  final dynamic originalError;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when server returns an error response
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred',
    super.code,
    super.originalError,
  });
}

/// Exception thrown when there is no internet connection
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
    super.originalError,
  });
}

/// Exception thrown when local cache operation fails
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.code,
    super.originalError,
  });
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed',
    super.code,
    super.originalError,
  });
}

/// Exception thrown when requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code,
    super.originalError,
  });
}
