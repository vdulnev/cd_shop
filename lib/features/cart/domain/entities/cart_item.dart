import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Represents an item in the shopping cart
class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  /// Total price for this cart item (product price * quantity)
  double get totalPrice => product.price * quantity;

  /// Creates a copy with updated quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

/// Represents the entire shopping cart
class Cart extends Equatable {
  const Cart({
    this.userId = '',
    this.items = const [],
  });

  final String userId;
  final List<CartItem> items;

  /// Total number of items in the cart (sum of all quantities)
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Total price of all items in the cart
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Whether the cart is empty
  bool get isEmpty => items.isEmpty;

  /// Whether the cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get cart item by product ID, or null if not found
  CartItem? getItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (_) {
      return null;
    }
  }

  /// Check if a product is in the cart
  bool containsProduct(String productId) {
    return items.any((item) => item.product.id == productId);
  }

  @override
  List<Object?> get props => [userId, items];
}
