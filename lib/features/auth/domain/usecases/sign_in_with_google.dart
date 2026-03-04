import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

/// Use case to sign in with Google
abstract interface class SignInWithGoogle implements UseCase<User, NoParams> {}

@LazySingleton(as: SignInWithGoogle)
class SignInWithGoogleImpl implements SignInWithGoogle {
  SignInWithGoogleImpl(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
