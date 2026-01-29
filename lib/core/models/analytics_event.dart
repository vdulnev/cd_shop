import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

sealed class AnalyticsEvent {
  const AnalyticsEvent();
}

class SignUpAnalyticsEvent extends AnalyticsEvent {
  const SignUpAnalyticsEvent();
}

class LoginAnalyticsEvent extends AnalyticsEvent {
  const LoginAnalyticsEvent();
}

class SetUserAnalyticsEvent extends AnalyticsEvent {
  const SetUserAnalyticsEvent({required this.user});
  final User? user;
}

class ViewProductAnalyticsEvent extends AnalyticsEvent {
  const ViewProductAnalyticsEvent({required this.product});
  final Product product;
}

class AddToCartAnalyticsEvent extends AnalyticsEvent {
  const AddToCartAnalyticsEvent({required this.product, required this.quantity});
  final Product product;
  final int quantity;
}

class RemoveFromCartAnalyticsEvent extends AnalyticsEvent {
  const RemoveFromCartAnalyticsEvent({
    required this.product,
    required this.quantity,
  });
  final Product product;
  final int quantity;
}

class BeginCheckoutAnalyticsEvent extends AnalyticsEvent {
  const BeginCheckoutAnalyticsEvent({
    required this.items,
    required this.total,
  });
  final List<CartItem> items;
  final double total;
}

class PurchaseAnalyticsEvent extends AnalyticsEvent {
  const PurchaseAnalyticsEvent({
    required this.orderId,
    required this.total,
    required this.shipping,
    required this.tax,
    required this.items,
  });
  final String orderId;
  final double total;
  final double shipping;
  final double tax;
  final List<CartItem> items;
}

class SearchAnalyticsEvent extends AnalyticsEvent {
  const SearchAnalyticsEvent({required this.query});
  final String query;
}
