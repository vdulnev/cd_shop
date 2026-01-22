import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/cart/presentation/pages/cart_page.dart';
import 'package:cd_shop/features/cart/presentation/pages/checkout_page.dart';

/// Route paths for cart feature
class CartRoutes {
  CartRoutes._();

  static const String cart = '/cart';
  static const String checkout = '/checkout';
}

/// Cart tab branch
StatefulShellBranch cartBranch() => StatefulShellBranch(
      routes: [
        GoRoute(
          path: CartRoutes.cart,
          name: 'cart',
          builder: (context, state) => const CartPage(),
          routes: [
            GoRoute(
              path: 'checkout',
              name: 'checkout',
              builder: (context, state) => const CheckoutPage(),
            ),
          ],
        ),
      ],
    );
