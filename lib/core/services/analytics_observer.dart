import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'package:cd_shop/core/models/analytics_event.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/injection_container.dart';

class AnalyticsObserver {
  AnalyticsObserver({
    required AnalyticsService analyticsService,
  }) : _analyticsService = analyticsService {
    final emitters = [
      sl<AuthRepository>(),
      sl<CartRepository>(),
      sl<OrderRepository>(),
      sl<ProductRepository>(),
    ].whereType<AnalyticsEmitter>().toList();

    _subscription = MergeStream<AnalyticsEvent>(
      emitters.map((e) => e.analyticsEventStream()).toList(),
    ).listen(_handleEvent);
  }

  final AnalyticsService _analyticsService;
  late final StreamSubscription<AnalyticsEvent> _subscription;

  void _handleEvent(AnalyticsEvent event) {
    switch (event) {
      case SignUpAnalyticsEvent():
        _analyticsService.logSignUp();
      case LoginAnalyticsEvent():
        _analyticsService.logLogin();
      case SetUserAnalyticsEvent(:final user):
        _analyticsService.setUser(user);
      case ViewProductAnalyticsEvent(:final product):
        _analyticsService.logViewProduct(product);
      case AddToCartAnalyticsEvent(:final product, :final quantity):
        _analyticsService.logAddToCart(product, quantity);
      case RemoveFromCartAnalyticsEvent(:final product, :final quantity):
        _analyticsService.logRemoveFromCart(product, quantity);
      case BeginCheckoutAnalyticsEvent(:final items, :final total):
        _analyticsService.logBeginCheckout(items, total);
      case PurchaseAnalyticsEvent(
        :final orderId,
        :final total,
        :final shipping,
        :final tax,
        :final items,
      ):
        _analyticsService.logPurchase(
          orderId: orderId,
          total: total,
          shipping: shipping,
          tax: tax,
          items: items,
        );
      case SearchAnalyticsEvent(:final query):
        _analyticsService.logSearch(query);
    }
  }

  void dispose() => _subscription.cancel();
}
