import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/database/daos/user_dao.dart';
import 'package:cd_shop/core/database/entities/user_entity.dart';
import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

/// Floor database implementation of AuthRepository
///
/// Persists users and session to SQLite using Floor.
class AuthRepositoryImpl
  with EventEmitterMixin
  implements AuthRepository {
  AuthRepositoryImpl({required UserDao userDao}) : _userDao = userDao;

  final UserDao _userDao;

  /// Simple password hashing (in production, use bcrypt or similar)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
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

      // Check if email already exists
      final existingUser = await _userDao.getUserByEmail(email);
      if (existingUser != null) {
        return const Left(
          ValidationFailure(message: 'Email already registered'),
        );
      }

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
      );

      // Save user to database
      await _userDao.insertUser(
        UserEntity.fromDomain(user, _hashPassword(password)),
      );

      // Set current session
      await _userDao.setCurrentSession(SessionEntity(id: 1, userId: user.id));

      emitEvent(SuccessEvent(message: 'Welcome, $name!'));
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure(message: 'Registration failed'));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userEntity = await _userDao.getUserByEmail(email);

      if (userEntity == null ||
          userEntity.passwordHash != _hashPassword(password)) {
        emitEvent(const ErrorEvent(message: 'Invalid email or password'));
        return const Left(AuthFailure(message: 'Invalid email or password'));
      }

      // Set current session
      await _userDao.setCurrentSession(
        SessionEntity(id: 1, userId: userEntity.id),
      );

      final user = userEntity.toDomain();
      emitEvent(SuccessEvent(message: 'Welcome back, ${user.name}!'));
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure(message: 'Login failed'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _userDao.clearSession();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Logout failed'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final session = await _userDao.getCurrentSession();
      if (session == null) {
        return const Right(null);
      }

      final userEntity = await _userDao.getUserById(session.userId);
      return Right(userEntity?.toDomain());
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get current user'));
    }
  }

  @override
  Stream<User?> watchCurrentUser() async* {
    final initialSession = await _userDao.getCurrentSession();
    if (initialSession == null) {
      yield null;
    } else {
      final userEntity = await _userDao.getUserById(initialSession.userId);
      yield userEntity?.toDomain();
    }

    yield* _userDao.watchCurrentSession().asyncMap((session) async {
      if (session == null) {
        return null;
      }
      final userEntity = await _userDao.getUserById(session.userId);
      return userEntity?.toDomain();
    });
  }

  void dispose() {
    disposeEventEmitter();
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String? addressId) async {
    try {
      final session = await _userDao.getCurrentSession();
      if (session == null) {
        return const Left(AuthFailure(message: 'Not logged in'));
      }

      if (addressId != null) {
        await _userDao.setDefaultAddress(session.userId, addressId);
      } else {
        await _userDao.clearDefaultAddress(session.userId);
      }
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to set default address'));
    }
  }

}
