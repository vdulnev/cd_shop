import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/auth/domain/entities/user.dart';

sealed class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();
}

class RegistrationLoading extends RegistrationState {
  const RegistrationLoading();
}

class RegistrationSuccess extends RegistrationState {
  const RegistrationSuccess(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}
