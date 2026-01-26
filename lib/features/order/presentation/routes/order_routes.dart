import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/order/presentation/pages/orders_page.dart';

/// Route paths for order feature
class OrderRoutes {
  OrderRoutes._();

  static const String orders = 'orders';
}

/// Data passed to orders page
class OrdersRouteData {
  const OrdersRouteData({required this.userId});

  final String userId;
}

/// Order routes under account
List<RouteBase> orderRoutes() => [
      GoRoute(
        path: OrderRoutes.orders,
        name: 'orders',
        builder: (context, state) {
          final data = state.extra as OrdersRouteData?;
          if (data == null) {
            return const Scaffold(
              body: Center(child: Text('Missing user data')),
            );
          }
          return OrdersPage(userId: data.userId);
        },
      ),
    ];
