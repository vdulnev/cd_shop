import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/core/widgets/app_event_widget.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:cd_shop/features/address/presentation/routes/address_routes.dart';
import 'package:cd_shop/features/auth/presentation/routes/auth_routes.dart';
import 'package:cd_shop/features/cart/presentation/routes/cart_routes.dart';
import 'package:cd_shop/features/product/presentation/routes/product_routes.dart';
import 'package:cd_shop/main_page.dart';

/// Application route paths (re-exports feature routes for convenience)
class AppRoutes {
  AppRoutes._();

  // Product routes
  static const String home = ProductRoutes.home;
  static const String products = ProductRoutes.products;
  static const String productDetail = ProductRoutes.productDetail;
  static const String search = ProductRoutes.search;

  // Cart routes
  static const String cart = CartRoutes.cart;
  static const String checkout = CartRoutes.checkout;

  // Auth routes
  static const String account = AuthRoutes.account;
  static const String login = AuthRoutes.login;
  static const String register = AuthRoutes.register;

  // Address routes
  static const String addresses = '/account/${AddressRoutes.addresses}';
  static const String addAddress = '/account/${AddressRoutes.addresses}/${AddressRoutes.addAddress}';
  static const String editAddress =
      '/account/${AddressRoutes.addresses}/${AddressRoutes.editAddress}';
}

/// Application router configuration using go_router
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    observers: [sl<AnalyticsService>().observer],
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppEventWidget(
            child: MainPage(navigationShell: navigationShell),
          );
        },
        branches: [
          productBranch(),
          searchBranch(),
          cartBranch(),
          accountBranch(),
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
