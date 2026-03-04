import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Sign in with Google account
  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> getCurrentUser();

  /// Watch the current signed-in user (or null if signed out)
  Stream<User?> watchCurrentUser();

  Future<Either<Failure, void>> setDefaultAddress(String? addressId);

}
