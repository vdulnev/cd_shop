import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/presentation/providers/login_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginNotifier extends Notifier<LoginState> {
  late final LoginUser _loginUser;

  @override
  LoginState build() {
    _loginUser = sl<LoginUser>();
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

  void reset() {
    state = const LoginInitial();
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);
