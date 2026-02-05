import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

/// Use case to logout the current user
abstract interface class LogoutUser implements UseCase<void, NoParams> {}

@LazySingleton(as: LogoutUser)
class LogoutUserImpl implements LogoutUser {
  LogoutUserImpl(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
