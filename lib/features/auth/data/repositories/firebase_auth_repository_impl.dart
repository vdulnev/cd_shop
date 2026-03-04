import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/analytics_event.dart';
import 'package:cd_shop/core/models/disposable.dart';
import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
///
/// Uses Firebase Auth for authentication and Firestore for user profiles.
@LazySingleton(as: AuthRepository)
class FirebaseAuthRepositoryImpl
    with EventEmitterMixin, AnalyticsEventBusMixin
    implements AuthRepository, Disposable {
  FirebaseAuthRepositoryImpl(this._firebaseAuth, this._firestore, this._googleSignIn);

  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

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
          message: 'Network error. Please check your connection.',
        );
      case 'too-many-requests':
        return const AuthFailure(
          message: 'Too many attempts. Please try again later.',
        );
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
          ValidationFailure(message: 'Password must be at least 6 characters'),
        );
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
      final user = User(id: firebaseUser.uid, email: email, name: name);

      await _usersRef.doc(firebaseUser.uid).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Track analytics
      emitAnalyticsEvent(const SignUpAnalyticsEvent());
      emitAnalyticsEvent(SetUserAnalyticsEvent(user: user));

      emitEvent(SuccessEvent(message: 'Welcome, $name!'));
      return Right(user);
    } on fb.FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthError(e);
      emitEvent(ErrorEvent(message: failure.message));
      return Left(failure);
    } catch (e) {
      const failure = ServerFailure(message: 'Registration failed');
      emitEvent(ErrorEvent(message: failure.message));
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
        name:
            userData?['name'] as String? ?? firebaseUser.displayName ?? 'User',
        avatarUrl: firebaseUser.photoURL,
        defaultAddressId: userData?['defaultAddressId'] as String?,
      );

      // Track analytics
      emitAnalyticsEvent(const LoginAnalyticsEvent());
      emitAnalyticsEvent(SetUserAnalyticsEvent(user: user));

      emitEvent(SuccessEvent(message: 'Welcome back, ${user.name}!'));
      return Right(user);
    } on fb.FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthError(e);
      emitEvent(ErrorEvent(message: failure.message));
      return Left(failure);
    } catch (e) {
      const failure = ServerFailure(message: 'Login failed');
      emitEvent(ErrorEvent(message: failure.message));
      return const Left(failure);
    }
  }

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure(message: 'Google sign-in cancelled'));
      }

      // Get Google auth credentials
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'Google sign-in failed'));
      }

      // Check if user exists in Firestore, create if not
      final userDoc = await _usersRef.doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        // Create new user profile
        await _usersRef.doc(firebaseUser.uid).set({
          'email': firebaseUser.email ?? googleUser.email,
          'name': firebaseUser.displayName ?? googleUser.displayName ?? 'User',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final userData = userDoc.data();

      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? googleUser.email,
        name: firebaseUser.displayName ?? googleUser.displayName ?? 'User',
        avatarUrl: firebaseUser.photoURL ?? googleUser.photoUrl,
        defaultAddressId: userData?['defaultAddressId'] as String?,
      );

      // Track analytics
      emitAnalyticsEvent(const LoginAnalyticsEvent());
      emitAnalyticsEvent(SetUserAnalyticsEvent(user: user));

      emitEvent(SuccessEvent(message: 'Welcome, ${user.name}!'));
      return Right(user);
    } on fb.FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthError(e);
      emitEvent(ErrorEvent(message: failure.message));
      return Left(failure);
    } catch (e) {
      const failure = ServerFailure(message: 'Google sign-in failed');
      emitEvent(ErrorEvent(message: failure.message));
      return const Left(failure);
    }
  }

  @override
  Future<Either<Failure, User>> signInWithApple() async {
    try {
      // Trigger Apple Sign In flow
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create Apple credential for Firebase
      final appleAuthProvider = fb.OAuthProvider('apple.com');
      final credential = appleAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with Apple credentials
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return const Left(AuthFailure(message: 'Apple sign-in failed'));
      }

      // Check if user exists in Firestore, create if not
      final userDoc = await _usersRef.doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        // Create new user profile
        // Note: Apple may not always provide email/name (user can hide it)
        final email = appleCredential.email ?? firebaseUser.email ?? '';
        final givenName = appleCredential.givenName ?? '';
        final familyName = appleCredential.familyName ?? '';
        final fullName = [givenName, familyName].where((s) => s.isNotEmpty).join(' ');

        await _usersRef.doc(firebaseUser.uid).set({
          'email': email,
          'name': fullName.isNotEmpty ? fullName : (firebaseUser.displayName ?? 'User'),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      final userData = userDoc.data();

      final givenName = appleCredential.givenName ?? '';
      final familyName = appleCredential.familyName ?? '';
      final fullName = [givenName, familyName].where((s) => s.isNotEmpty).join(' ');

      final user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? appleCredential.email ?? '',
        name: firebaseUser.displayName ?? (fullName.isNotEmpty ? fullName : 'User'),
        avatarUrl: firebaseUser.photoURL,
        defaultAddressId: userData?['defaultAddressId'] as String?,
      );

      // Track analytics
      emitAnalyticsEvent(const LoginAnalyticsEvent());
      emitAnalyticsEvent(SetUserAnalyticsEvent(user: user));

      emitEvent(SuccessEvent(message: 'Welcome, ${user.name}!'));
      return Right(user);
    } on fb.FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthError(e);
      emitEvent(ErrorEvent(message: failure.message));
      return Left(failure);
    } on AuthorizationErrorCode catch (e) {
      String message;
      switch (e) {
        case AuthorizationErrorCode.canceled:
          message = 'Apple sign-in cancelled';
          break;
        case AuthorizationErrorCode.failed:
          message = 'Apple sign-in failed';
          break;
        case AuthorizationErrorCode.invalidResponse:
          message = 'Invalid response from Apple';
          break;
        case AuthorizationErrorCode.notInteractive:
          message = 'Apple sign-in not available';
          break;
        default:
          message = 'Apple sign-in error';
      }
      final failure = AuthFailure(message: message);
      emitEvent(ErrorEvent(message: message));
      return Left(failure);
    } catch (e) {
      const failure = ServerFailure(message: 'Apple sign-in failed');
      emitEvent(ErrorEvent(message: failure.message));
      return const Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      emitAnalyticsEvent(const SetUserAnalyticsEvent(user: null));
      await _googleSignIn.signOut();
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

      return Right(
        User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name:
              userData?['name'] as String? ??
              firebaseUser.displayName ??
              'User',
          avatarUrl: firebaseUser.photoURL,
          defaultAddressId: userData?['defaultAddressId'] as String?,
        ),
      );
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
          name:
              userData?['name'] as String? ??
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
      return const Left(
        ServerFailure(message: 'Failed to set default address'),
      );
    }
  }

  @override
  void dispose() {
    disposeEventEmitter();
  }
}
