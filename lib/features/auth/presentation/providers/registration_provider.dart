import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';
import 'package:cd_shop/features/auth/presentation/providers/registration_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/legacy.dart';

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier({required RegisterUser registerUser})
      : _registerUser = registerUser,
        super(const RegistrationInitial());

  final RegisterUser _registerUser;

  Future<void> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const RegistrationLoading();

    final result = await _registerUser(
      RegisterParams(
        email: email,
        password: password,
        name: name,
      ),
    );

    result.fold(
      (_) => state = const RegistrationInitial(),
      (user) => state = RegistrationSuccess(user),
    );
  }

  void reset() {
    state = const RegistrationInitial();
  }
}

final registrationProvider =
    StateNotifierProvider.autoDispose<RegistrationNotifier, RegistrationState>(
  (ref) {
    return RegistrationNotifier(registerUser: sl<RegisterUser>());
  },
);
