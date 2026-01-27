import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartItemAdded extends CartEvent {
  const CartItemAdded(this.product, {this.quantity = 1});

  final Product product;
  final int quantity;

  @override
  List<Object?> get props => [product, quantity];
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

class CartItemQuantityUpdated extends CartEvent {
  const CartItemQuantityUpdated(this.productId, this.quantity);

  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartUpdated extends CartEvent {
  const CartUpdated(this.cart);

  final Cart cart;

  @override
  List<Object?> get props => [cart];
}
