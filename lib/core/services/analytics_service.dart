import 'package:injectable/injectable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Service wrapper for Firebase Analytics.
///
/// Provides typed methods for tracking e-commerce events.
@lazySingleton
class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  /// Get the analytics observer for navigation tracking.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Set user ID when authenticated, or clear when logged out.
  Future<void> setUser(User? user) async {
    if (user != null) {
      await _analytics.setUserId(id: user.id);
      await _analytics.setUserProperty(name: 'user_email', value: user.email);
    } else {
      await _analytics.setUserId(id: null);
    }
  }

  /// Track login event.
  Future<void> logLogin({String method = 'email'}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Track sign up event.
  Future<void> logSignUp({String method = 'email'}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Track product view.
  Future<void> logViewProduct(Product product) async {
    await _analytics.logViewItem(
      currency: 'USD',
      value: product.price,
      items: [
        AnalyticsEventItem(
          itemId: product.id,
          itemName: product.title,
          itemCategory: product.genre.name,
          price: product.price,
        ),
      ],
    );
  }

  /// Track add to cart.
  Future<void> logAddToCart(Product product, int quantity) async {
    await _analytics.logAddToCart(
      currency: 'USD',
      value: product.price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: product.id,
          itemName: product.title,
          itemCategory: product.genre.name,
          price: product.price,
          quantity: quantity,
        ),
      ],
    );
  }

  /// Track remove from cart.
  Future<void> logRemoveFromCart(Product product, int quantity) async {
    await _analytics.logRemoveFromCart(
      currency: 'USD',
      value: product.price * quantity,
      items: [
        AnalyticsEventItem(
          itemId: product.id,
          itemName: product.title,
          price: product.price,
          quantity: quantity,
        ),
      ],
    );
  }

  /// Track begin checkout.
  Future<void> logBeginCheckout(List<CartItem> items, double total) async {
    await _analytics.logBeginCheckout(
      currency: 'USD',
      value: total,
      items: items
          .map(
            (item) => AnalyticsEventItem(
              itemId: item.product.id,
              itemName: item.product.title,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
    );
  }

  /// Track purchase completion.
  Future<void> logPurchase({
    required String orderId,
    required double total,
    required double shipping,
    required double tax,
    required List<CartItem> items,
  }) async {
    await _analytics.logPurchase(
      transactionId: orderId,
      currency: 'USD',
      value: total,
      shipping: shipping,
      tax: tax,
      items: items
          .map(
            (item) => AnalyticsEventItem(
              itemId: item.product.id,
              itemName: item.product.title,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList(),
    );
  }

  /// Track search query.
  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  /// Track screen view.
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Track custom events.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
