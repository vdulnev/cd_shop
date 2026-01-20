import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Map<String, _MockUser> _registeredUsers = {};
  User? _currentUser;

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (email.isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure(message: 'Invalid email address'));
    }

    if (password.length < 6) {
      return const Left(
        ValidationFailure(message: 'Password must be at least 6 characters'),
      );
    }

    if (name.isEmpty) {
      return const Left(ValidationFailure(message: 'Name is required'));
    }

    if (_registeredUsers.containsKey(email)) {
      return const Left(
        ValidationFailure(message: 'Email already registered'),
      );
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
    );

    _registeredUsers[email] = _MockUser(
      user: user,
      password: password,
    );

    _currentUser = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final mockUser = _registeredUsers[email];
    if (mockUser == null || mockUser.password != password) {
      return const Left(AuthFailure(message: 'Invalid email or password'));
    }

    _currentUser = mockUser.user;
    return Right(mockUser.user);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return Right(_currentUser);
  }
}

class _MockUser {
  _MockUser({required this.user, required this.password});

  final User user;
  final String password;
}
