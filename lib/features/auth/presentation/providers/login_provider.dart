import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:cd_shop/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:cd_shop/features/auth/presentation/providers/login_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginNotifier extends Notifier<LoginState> {
  late final LoginUser _loginUser;
  late final SignInWithGoogle _signInWithGoogle;
  late final SignInWithApple _signInWithApple;

  @override
  LoginState build() {
    _loginUser = sl<LoginUser>();
    _signInWithGoogle = sl<SignInWithGoogle>();
    _signInWithApple = sl<SignInWithApple>();
    return const LoginInitial();
  }

  Future<void> login(String email, String password) async {
    state = const LoginLoading();

    final result = await _loginUser(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = const LoginInitial(),
      (user) => state = LoginSuccess(user),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const LoginLoading();

    final result = await _signInWithGoogle(const NoParams());

    result.fold(
      (failure) => state = const LoginInitial(),
      (user) => state = LoginSuccess(user),
    );
  }

  Future<void> signInWithApple() async {
    state = const LoginLoading();

    final result = await _signInWithApple(const NoParams());

    result.fold(
      (failure) => state = const LoginInitial(),
      (user) => state = LoginSuccess(user),
    );
  }

  void reset() {
    state = const LoginInitial();
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
