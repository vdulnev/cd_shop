import 'package:equatable/equatable.dart';

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
