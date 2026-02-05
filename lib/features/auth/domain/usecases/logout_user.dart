import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class LogoutUser implements UseCase<void, NoParams> {
  LogoutUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
