import 'package:auto_route/auto_route.dart';

import 'package:cd_shop/router/app_router.gr.dart';

final orderRoutes = [
  AutoRoute(path: 'orders', page: OrdersRoute.page),
];
