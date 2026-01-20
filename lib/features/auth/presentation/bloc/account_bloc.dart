import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';

// Events
sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class AccountLoaded extends AccountEvent {
  const AccountLoaded();
}

class AccountLogoutRequested extends AccountEvent {
  const AccountLogoutRequested();
}

// States
sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountAuthenticated extends AccountState {
  const AccountAuthenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

class AccountUnauthenticated extends AccountState {
  const AccountUnauthenticated();
}

class AccountLoggedOut extends AccountState {
  const AccountLoggedOut();
}

class AccountError extends AccountState {
  const AccountError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc
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
