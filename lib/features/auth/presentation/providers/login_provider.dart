import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/presentation/providers/login_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/legacy.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier({required LoginUser loginUser})
      : _loginUser = loginUser,
        super(const LoginInitial());

  final LoginUser _loginUser;

  Future<void> submit({
    required String email,
    required String password,
  }) async {
    state = const LoginLoading();

    final result = await _loginUser(
      LoginParams(
        email: email,
        password: password,
      ),
    );

    result.fold(
      (_) => state = const LoginInitial(),
      (user) => state = LoginSuccess(user),
    );
  }

  void reset() {
    state = const LoginInitial();
  }
}

final loginProvider = StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) {
    return LoginNotifier(loginUser: sl<LoginUser>());
  },
);
