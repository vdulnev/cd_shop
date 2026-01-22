import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/auth/presentation/pages/account_page.dart';
import 'package:cd_shop/features/auth/presentation/pages/login_page.dart';
import 'package:cd_shop/features/auth/presentation/pages/registration_page.dart';
import 'package:cd_shop/features/cart/presentation/pages/cart_page.dart';
import 'package:cd_shop/features/cart/presentation/pages/checkout_page.dart';
import 'package:cd_shop/main_page.dart';
import 'package:cd_shop/features/product/presentation/pages/product_detail_page.dart';
import 'package:cd_shop/features/product/presentation/pages/product_list_page.dart';
import 'package:cd_shop/features/product/presentation/pages/product_search_page.dart';

/// Application route paths
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String search = '/search';
  static const String account = '/account';
  static const String login = '/account/login';
  static const String register = '/account/register';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
}

/// Application router configuration using go_router
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainPage(navigationShell: navigationShell);
        },
        branches: [
          // Products tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const ProductListPage(),
                routes: [
                  GoRoute(
                    path: 'products/:id',
                    name: 'productDetail',
                    builder: (context, state) {
                      final productId = state.pathParameters['id'] ?? '';
                      return ProductDetailPage(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Search tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (context, state) => const ProductSearchPage(),
                routes: [
                  GoRoute(
                    path: 'products/:id',
                    name: 'searchProductDetail',
                    builder: (context, state) {
                      final productId = state.pathParameters['id'] ?? '';
                      return ProductDetailPage(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Cart tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
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
          ),
          // Account tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.account,
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
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
