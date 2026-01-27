import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/cart/domain/usecases/watch_cart.dart';

import 'cart_event.dart';
import 'cart_state.dart';

export 'cart_event.dart';
export 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({
    required AddToCart addToCart,
    required RemoveFromCart removeFromCart,
    required UpdateCartQuantity updateCartQuantity,
    required ClearCart clearCart,
    required WatchCart watchCart,
  })  : _addToCart = addToCart,
        _removeFromCart = removeFromCart,
        _updateCartQuantity = updateCartQuantity,
        _clearCart = clearCart,
        _watchCart = watchCart,
        super(const CartInitial()) {
    on<CartStarted>(_onStarted);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityUpdated>(_onQuantityUpdated);
    on<CartCleared>(_onCleared);
    on<CartUpdated>(_onCartUpdated);
  }

  final AddToCart _addToCart;
  final RemoveFromCart _removeFromCart;
  final UpdateCartQuantity _updateCartQuantity;
  final ClearCart _clearCart;
  final WatchCart _watchCart;

  StreamSubscription<Cart>? _cartSubscription;

  Future<void> _onStarted(
    CartStarted event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    await _startCartSubscription();
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
      (_) {},
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
      (_) {},
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
      (_) {},
    );
  }

  Future<void> _onCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    final result = await _clearCart(const NoParams());

    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onCartUpdated(
    CartUpdated event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoaded(event.cart));
  }

  Future<void> _startCartSubscription() async {
    await _cartSubscription?.cancel();
    _cartSubscription = _watchCart().listen((cart) => add(CartUpdated(cart)));
  }

  @override
  Future<void> close() async {
    await _cartSubscription?.cancel();
    return super.close();
  }
}
