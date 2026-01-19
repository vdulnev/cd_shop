import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Failures represent expected error states that should be handled gracefully.
abstract class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
  });

  final String message;
  final int? code;

  @override
  List<Object?> get props => [message, code];
}

/// Failure when server returns an error response
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });
}

/// Failure when there is no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Failure when local cache operation fails
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred',
    super.code,
  });
}

/// Failure when authentication fails or token expires
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
    super.code,
  });
}

/// Failure when requested resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code,
  });
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed',
    super.code,
    this.fieldErrors,
  });

  final Map<String, String>? fieldErrors;

  @override
  List<Object?> get props => [message, code, fieldErrors];
}
