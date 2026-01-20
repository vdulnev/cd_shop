import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';

// Events
sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted({
    required this.email,
    required this.password,
    required this.name,
  });

  final String email;
  final String password;
  final String name;

  @override
  List<Object?> get props => [email, password, name];
}

// States
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

class RegistrationFailure extends RegistrationState {
  const RegistrationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({required RegisterUser registerUser})
      : _registerUser = registerUser,
        super(const RegistrationInitial()) {
    on<RegistrationSubmitted>(_onSubmitted);
  }

  final RegisterUser _registerUser;

  Future<void> _onSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    final result = await _registerUser(
      RegisterParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    result.fold(
      (failure) => emit(RegistrationFailure(failure.message)),
      (user) => emit(RegistrationSuccess(user)),
    );
  }
}
