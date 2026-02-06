import 'package:auto_route/auto_route.dart';

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
              children: [
                AutoRoute(path: '', page: ProductListRoute.page),
                AutoRoute(path: ':id', page: ProductDetailRoute.page),
              ],
            ),
            AutoRoute(
              path: 'search',
              page: SearchTab.page,
              children: [
                AutoRoute(path: '', page: ProductSearchRoute.page),
                AutoRoute(
                    path: 'products/:id', page: ProductDetailRoute.page),
              ],
            ),
            AutoRoute(
              path: 'cart',
              page: CartTab.page,
              children: [
                AutoRoute(path: '', page: CartRoute.page),
                AutoRoute(path: 'checkout', page: CheckoutRoute.page),
              ],
            ),
            AutoRoute(
              path: 'account',
              page: AccountTab.page,
              children: [
                AutoRoute(path: '', page: AccountRoute.page),
                AutoRoute(path: 'login', page: LoginRoute.page),
                AutoRoute(path: 'register', page: RegistrationRoute.page),
                AutoRoute(path: 'addresses', page: AddressesRoute.page),
                AutoRoute(
                    path: 'addresses/add', page: AddAddressRoute.page),
                AutoRoute(
                    path: 'addresses/edit', page: EditAddressRoute.page),
                AutoRoute(path: 'orders', page: OrdersRoute.page),
              ],
            ),
          ],
        ),
      ];
}
