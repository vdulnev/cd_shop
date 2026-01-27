import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';

import 'account_event.dart';
import 'account_state.dart';

export 'account_event.dart';
export 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({
    required GetCurrentUser getCurrentUser,
    required LogoutUser logoutUser,
  })  : _getCurrentUser = getCurrentUser,
        _logoutUser = logoutUser,
        super(const AccountInitial()) {
    on<AccountLoaded>(_onLoaded);
    on<AccountLogoutRequested>(_onLogoutRequested);
  }

  final GetCurrentUser _getCurrentUser;
  final LogoutUser _logoutUser;

  Future<void> _onLoaded(
    AccountLoaded event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());

    final result = await _getCurrentUser(const NoParams());

    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (user) {
        if (user != null) {
          emit(AccountAuthenticated(user));
        } else {
          emit(const AccountUnauthenticated());
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    AccountLogoutRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(const AccountLoading());

    final result = await _logoutUser(const NoParams());

    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (_) => emit(const AccountLoggedOut()),
    );
  }
}
