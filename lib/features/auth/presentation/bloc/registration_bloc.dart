import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';

import 'registration_event.dart';
import 'registration_state.dart';

export 'registration_event.dart';
export 'registration_state.dart';

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
      (failure) => emit(const RegistrationInitial()),
      (user) => emit(RegistrationSuccess(user)),
    );
  }
}
