import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base class for all use cases in the application.
/// Use cases encapsulate a single piece of business logic.
///
/// [T] is the return type of the use case.
/// [Params] is the parameter type required by the use case.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use this class when a use case doesn't require any parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
