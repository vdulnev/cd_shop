import 'dart:async';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/watch_current_user.dart';
import 'package:cd_shop/features/auth/presentation/providers/account_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountNotifier extends Notifier<AccountState> {
  late final GetCurrentUser _getCurrentUser;
  late final LogoutUser _logoutUser;
  late final WatchCurrentUser _watchCurrentUser;
  StreamSubscription? _subscription;

  @override
  AccountState build() {
    _getCurrentUser = sl<GetCurrentUser>();
    _logoutUser = sl<LogoutUser>();
    _watchCurrentUser = sl<WatchCurrentUser>();
    _subscribe();
    return const AccountLoading();
  }

  void _subscribe() {
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

    ref.onDispose(() {
      _subscription?.cancel();
    });
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
}

final accountProvider = NotifierProvider<AccountNotifier, AccountState>(
  AccountNotifier.new,
);
