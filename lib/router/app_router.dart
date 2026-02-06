import 'package:auto_route/auto_route.dart';

import 'package:cd_shop/features/address/presentation/routes/address_routes.dart';
import 'package:cd_shop/features/auth/presentation/routes/auth_routes.dart';
import 'package:cd_shop/features/cart/presentation/routes/cart_routes.dart';
import 'package:cd_shop/features/order/presentation/routes/order_routes.dart';
import 'package:cd_shop/features/product/presentation/routes/product_routes.dart';
import 'package:cd_shop/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/',
          page: MainRoute.page,
          initial: true,
          children: [
            AutoRoute(
              path: 'products',
              page: ProductsTab.page,
              children: productRoutes,
            ),
            AutoRoute(
              path: 'search',
              page: SearchTab.page,
              children: searchRoutes,
            ),
            AutoRoute(
              path: 'cart',
              page: CartTab.page,
              children: cartRoutes,
            ),
            AutoRoute(
              path: 'account',
              page: AccountTab.page,
              children: [
                ...authRoutes,
                ...addressRoutes,
                ...orderRoutes,
              ],
            ),
          ],
        ),
      ];
}
