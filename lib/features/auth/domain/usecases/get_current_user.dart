import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class GetCurrentUser implements UseCase<User?, NoParams> {
  GetCurrentUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, User?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
