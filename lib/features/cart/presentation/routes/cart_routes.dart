import 'package:auto_route/auto_route.dart';

import 'package:cd_shop/router/app_router.gr.dart';

final cartRoutes = [
  AutoRoute(path: '', page: CartRoute.page),
  AutoRoute(path: 'checkout', page: CheckoutRoute.page),
];
