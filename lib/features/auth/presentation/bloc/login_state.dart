import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/auth/domain/entities/user.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}
