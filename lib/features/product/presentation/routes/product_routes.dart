import 'package:auto_route/auto_route.dart';

import 'package:cd_shop/router/app_router.gr.dart';

final productRoutes = [
  AutoRoute(path: '', page: ProductListRoute.page),
  AutoRoute(path: ':id', page: ProductDetailRoute.page),
];

final searchRoutes = [
  AutoRoute(path: '', page: ProductSearchRoute.page),
  AutoRoute(path: 'products/:id', page: ProductDetailRoute.page),
];
