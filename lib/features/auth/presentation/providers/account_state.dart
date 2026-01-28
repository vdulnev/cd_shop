import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/auth/domain/entities/user.dart';

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
