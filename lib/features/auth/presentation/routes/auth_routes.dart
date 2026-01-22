import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/auth/presentation/pages/account_page.dart';
import 'package:cd_shop/features/auth/presentation/pages/login_page.dart';
import 'package:cd_shop/features/auth/presentation/pages/registration_page.dart';

/// Route paths for auth feature
class AuthRoutes {
  AuthRoutes._();

  static const String account = '/account';
  static const String login = '/account/login';
  static const String register = '/account/register';
}

/// Account tab branch
StatefulShellBranch accountBranch() => StatefulShellBranch(
      routes: [
        GoRoute(
          path: AuthRoutes.account,
          name: 'account',
          builder: (context, state) => const AccountPage(),
          routes: [
            GoRoute(
              path: 'login',
              name: 'login',
              builder: (context, state) => const LoginPage(),
            ),
            GoRoute(
              path: 'register',
              name: 'register',
              builder: (context, state) => const RegistrationPage(),
            ),
          ],
        ),
      ],
    );
