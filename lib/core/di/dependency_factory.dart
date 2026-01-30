import 'package:talker/talker.dart';

import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/core/services/analytics_observer.dart';
import 'package:cd_shop/core/services/analytics_service.dart';

/// Abstract factory for creating dependencies.
///
/// [FirebaseDependencyFactory] provides real Firebase implementations.
/// Tests provide their own implementation with mocks.
abstract class DependencyFactory {
  Talker createTalker();
  AnalyticsService createAnalyticsService();
  AnalyticsObserver createAnalyticsObserver({
    required AnalyticsService analyticsService,
  });
  AuthRepository createAuthRepository();
  ProductRepository createProductRepository();
  CartRepository createCartRepository();
  AddressRepository createAddressRepository();
  OrderRepository createOrderRepository();
}
