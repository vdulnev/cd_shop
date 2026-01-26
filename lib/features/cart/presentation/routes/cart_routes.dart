import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/presentation/pages/cart_page.dart';
import 'package:cd_shop/features/cart/presentation/pages/checkout_page.dart';

/// Route paths for cart feature
class CartRoutes {
  CartRoutes._();

  static const String cart = '/cart';
  static const String checkout = '/checkout';
}

/// Data passed to checkout page
class CheckoutRouteData {
  const CheckoutRouteData({
    required this.userId,
    required this.cartItems,
  });

  final String userId;
  final List<CartItem> cartItems;
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
              builder: (context, state) {
                final data = state.extra as CheckoutRouteData?;
                if (data == null) {
                  return const Scaffold(
                    body: Center(child: Text('Missing checkout data')),
                  );
                }
                return CheckoutPage(
                  userId: data.userId,
                  cartItems: data.cartItems,
                );
              },
            ),
          ],
        ),
      ],
    );
