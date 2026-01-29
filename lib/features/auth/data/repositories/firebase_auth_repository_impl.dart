import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/analytics_event.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
///
/// Uses Firebase Auth for authentication and Firestore for user profiles.
class FirebaseAuthRepositoryImpl implements AuthRepository {
  FirebaseAuthRepositoryImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    this.analyticsEventBus,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final AnalyticsEventBus? analyticsEventBus;

  final _eventController = StreamController<RepositoryEvent>.broadcast();

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Map Firebase Auth errors to app Failure types.
  Failure _mapFirebaseAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(message: 'Invalid email or password');
      case 'email-already-in-use':
        return const ValidationFailure(message: 'Email already registered');
      case 'weak-password':
        return const ValidationFailure(message: 'Password is too weak');
      case 'invalid-email':
        return const ValidationFailure(message: 'Invalid email address');
      case 'network-request-failed':
        return const NetworkFailure(
            message: 'Network error. Please check your connection.');
      case 'too-many-requests':
        return const AuthFailure(
            message: 'Too many attempts. Please try again later.');
      case 'user-disabled':
        return const AuthFailure(message: 'This account has been disabled');
      default:
        return AuthFailure(message: e.message ?? 'Authentication failed');
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || !email.contains('@')) {
        return const Left(ValidationFailure(message: 'Invalid email address'));
      }
      if (password.length < 6) {
        return const Left(
            ValidationFailure(message: 'Password must be at least 6 characters'));
      }
      if (name.isEmpty) {
        return const Left(ValidationFailure(message: 'Name is required'));
      }

      // Create Firebase Auth user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const Left(ServerFailure(message: 'Registration failed'));
      }

      // Update display name
      await firebaseUser.updateDisplayName(name);

      // Create user profile in Firestore
      final user = User(
        id: firebaseUser.uid,
        email: email,
        name: name,
      );

      await _usersRef.doc(firebaseUser.uid).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Track analytics
      analyticsEventBus?.emit(const SignUpAnalyticsEvent());
      analyticsEventBus?.emit(SetUserAnalyticsEvent(user: user));

      _eventController.add(SuccessEvent(message: 'Welcome, $name!'));
      return Right(user);
    } on fb.FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthError(e);
      _eventController.add(ErrorEvent(message: failure.message));
      return Left(failure);
    } catch (e) {
      const failure = ServerFailure(message: 'Registration failed');
      _eventController.add(ErrorEvent(message: failure.message));
      return const Left(failure);
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'Login failed'));
      }

      // Fetch user profile from Firestore
      final userDoc = await _usersRef.doc(firebaseUser.uid).get();
      final userData = userDoc.data();

      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: userData?['name'] as String? ??
            firebaseUser.displayName ??
            'User',
        avatarUrl: firebaseUser.photoURL,
        defaultAddressId: userData?['defaultAddressId'] as String?,
      );

      // Track analytics
      analyticsEventBus?.emit(const LoginAnalyticsEvent());
      analyticsEventBus?.emit(SetUserAnalyticsEvent(user: user));

      _eventController.add(SuccessEvent(message: 'Welcome back, ${user.name}!'));
      return Right(user);
    } on fb.FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthError(e);
      _eventController.add(ErrorEvent(message: failure.message));
      return Left(failure);
    } catch (e) {
      const failure = ServerFailure(message: 'Login failed');
      _eventController.add(ErrorEvent(message: failure.message));
      return const Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      analyticsEventBus?.emit(const SetUserAnalyticsEvent(user: null));
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Logout failed'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const Right(null);
      }

      final userDoc = await _usersRef.doc(firebaseUser.uid).get();
      final userData = userDoc.data();

      return Right(User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: userData?['name'] as String? ??
            firebaseUser.displayName ??
            'User',
        avatarUrl: firebaseUser.photoURL,
        defaultAddressId: userData?['defaultAddressId'] as String?,
      ));
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to get current user'));
    }
  }

  @override
  Stream<User?> watchCurrentUser() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _usersRef.doc(firebaseUser.uid).get();
        final userData = userDoc.data();

        return User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: userData?['name'] as String? ??
              firebaseUser.displayName ??
              'User',
          avatarUrl: firebaseUser.photoURL,
          defaultAddressId: userData?['defaultAddressId'] as String?,
        );
      } catch (_) {
        // If Firestore fetch fails, return basic user from Firebase Auth
        return User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          avatarUrl: firebaseUser.photoURL,
        );
      }
    });
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String? addressId) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'Not logged in'));
      }

      await _usersRef.doc(firebaseUser.uid).update({
        'defaultAddressId': addressId,
      });

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to set default address'));
    }
  }

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;
}
