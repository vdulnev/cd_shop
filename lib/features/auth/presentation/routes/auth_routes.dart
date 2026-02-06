import 'package:auto_route/auto_route.dart';

import 'package:cd_shop/router/app_router.gr.dart';

final authRoutes = [
  AutoRoute(path: '', page: AccountRoute.page),
  AutoRoute(path: 'login', page: LoginRoute.page),
  AutoRoute(path: 'register', page: RegistrationRoute.page),
];
