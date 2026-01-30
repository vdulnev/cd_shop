import 'dart:async';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/watch_current_user.dart';
import 'package:cd_shop/features/auth/presentation/providers/account_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/legacy.dart';

class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier({
    required GetCurrentUser getCurrentUser,
    required LogoutUser logoutUser,
    required WatchCurrentUser watchCurrentUser,
  })  : _getCurrentUser = getCurrentUser,
        _logoutUser = logoutUser,
        _watchCurrentUser = watchCurrentUser,
        super(const AccountInitial()) {
    _subscribe();
  }

  final GetCurrentUser _getCurrentUser;
  final LogoutUser _logoutUser;
  final WatchCurrentUser _watchCurrentUser;
  StreamSubscription? _subscription;

  void _subscribe() {
    state = const AccountLoading();
    _subscription?.cancel();
    _subscription = _watchCurrentUser().listen(
      (user) {
        if (user != null) {
          state = AccountAuthenticated(user);
        } else {
          state = const AccountUnauthenticated();
        }
      },
      onError: (error) {
        state = AccountError(error.toString());
      },
    );
  }

  Future<void> load() async {
    state = const AccountLoading();

    final result = await _getCurrentUser(const NoParams());

    result.fold(
      (failure) => state = AccountError(failure.message),
      (user) {
        if (user != null) {
          state = AccountAuthenticated(user);
        } else {
          state = const AccountUnauthenticated();
        }
      },
    );
  }

  Future<void> logout() async {
    state = const AccountLoading();

    final result = await _logoutUser(const NoParams());

    result.fold(
      (failure) => state = AccountError(failure.message),
      (_) => state = const AccountLoggedOut(),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((
  ref,
) {
  return AccountNotifier(
    getCurrentUser: sl<GetCurrentUser>(),
    logoutUser: sl<LogoutUser>(),
    watchCurrentUser: sl<WatchCurrentUser>(),
  );
});
