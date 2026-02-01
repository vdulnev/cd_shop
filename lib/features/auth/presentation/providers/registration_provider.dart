import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';
import 'package:cd_shop/features/auth/presentation/providers/registration_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationNotifier extends Notifier<RegistrationState> {
  late final RegisterUser _registerUser;

  @override
  RegistrationState build() {
    _registerUser = sl<RegisterUser>();
    return const RegistrationInitial();
  }

  Future<void> register(String email, String password, String name) async {
    state = const RegistrationLoading();

    final result = await _registerUser(
      RegisterParams(email: email, password: password, name: name),
    );

    result.fold(
      (failure) => state = const RegistrationInitial(),
      (user) => state = RegistrationSuccess(user),
    );
  }

  void reset() {
    state = const RegistrationInitial();
  }
}

final registrationProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(
  RegistrationNotifier.new,
);
