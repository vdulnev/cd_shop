import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';

import 'login_event.dart';
import 'login_state.dart';

export 'login_event.dart';
export 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required LoginUser loginUser})
      : _loginUser = loginUser,
        super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUser _loginUser;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _loginUser(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(const LoginInitial()),
      (user) => emit(LoginSuccess(user)),
    );
  }
}
