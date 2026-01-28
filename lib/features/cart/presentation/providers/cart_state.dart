import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';

sealed class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  const CartLoaded(this.cart);

  final Cart cart;

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  const CartError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
