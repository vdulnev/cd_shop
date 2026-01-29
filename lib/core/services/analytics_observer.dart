import 'dart:async';

import 'package:cd_shop/core/models/analytics_event.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/core/services/analytics_service.dart';

class AnalyticsObserver {
  AnalyticsObserver({
    required AnalyticsService analyticsService,
    required AnalyticsEventBus eventBus,
  }) : _analyticsService = analyticsService {
    _subscription = eventBus.stream.listen(_handleEvent);
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
