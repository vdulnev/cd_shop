import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/get_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

// Events
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

// States
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

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required GetCart getCart,
    required AddToCart addToCart,
    required RemoveFromCart removeFromCart,
    required UpdateCartQuantity updateCartQuantity,
    required ClearCart clearCart,
  })  : _getCart = getCart,
        _addToCart = addToCart,
        _removeFromCart = removeFromCart,
        _updateCartQuantity = updateCartQuantity,
        _clearCart = clearCart,
        super(const CartInitial()) {
    on<CartStarted>(_onStarted);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityUpdated>(_onQuantityUpdated);
    on<CartCleared>(_onCleared);
  }

  final GetCart _getCart;
  final AddToCart _addToCart;
  final RemoveFromCart _removeFromCart;
  final UpdateCartQuantity _updateCartQuantity;
  final ClearCart _clearCart;

  Future<void> _onStarted(
    CartStarted event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());

    final result = await _getCart(const NoParams());

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final result = await _addToCart(
      AddToCartParams(product: event.product, quantity: event.quantity),
    );

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final result = await _removeFromCart(
      RemoveFromCartParams(productId: event.productId),
    );

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    final result = await _updateCartQuantity(
      UpdateCartQuantityParams(
        productId: event.productId,
        quantity: event.quantity,
      ),
    );

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> _onCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    final result = await _clearCart(const NoParams());

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }
}
