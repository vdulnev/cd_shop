import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  final Map<String, _MockUser> _registeredUsers = {};
  User? _currentUser;
  final _eventController = StreamController<RepositoryEvent>.broadcast();

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
    _eventController.add(AuthSuccessEvent(message: 'Welcome, $name!'));
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
      _eventController.add(
        const AuthErrorEvent(message: 'Invalid email or password'),
      );
      return const Left(AuthFailure(message: 'Invalid email or password'));
    }

    _currentUser = mockUser.user;
    _eventController.add(
      AuthSuccessEvent(message: 'Welcome back, ${mockUser.user.name}!'),
    );
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

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;
}

class _MockUser {
  _MockUser({required this.user, required this.password});

  final User user;
  final String password;
}
