import 'dart:async';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/cart/domain/usecases/watch_cart.dart';
import 'package:cd_shop/features/cart/presentation/providers/cart_state.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartNotifier extends Notifier<CartState> {
  late final WatchCart _watchCart;
  late final AddToCart _addToCart;
  late final RemoveFromCart _removeFromCart;
  late final UpdateCartQuantity _updateCartQuantity;
  late final ClearCart _clearCart;
  StreamSubscription? _subscription;

  @override
  CartState build() {
    _watchCart = sl<WatchCart>();
    _addToCart = sl<AddToCart>();
    _removeFromCart = sl<RemoveFromCart>();
    _updateCartQuantity = sl<UpdateCartQuantity>();
    _clearCart = sl<ClearCart>();
    _subscribe();
    return const CartInitial();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _watchCart().listen(
      (cart) {
        state = CartLoaded(cart);
      },
      onError: (error) {
        state = CartError(error.toString());
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  Future<void> addProduct(Product product, int quantity) async {
    final result = await _addToCart(
      AddToCartParams(product: product, quantity: quantity),
    );

    result.fold(
      (failure) => state = CartError(failure.message),
      (_) {},
    );
  }

  Future<void> removeProduct(String productId) async {
    final result = await _removeFromCart(
      RemoveFromCartParams(productId: productId),
    );

    result.fold(
      (failure) => state = CartError(failure.message),
      (_) {},
    );
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final result = await _updateCartQuantity(
      UpdateCartQuantityParams(productId: productId, quantity: quantity),
    );

    result.fold(
      (failure) => state = CartError(failure.message),
      (_) {},
    );
  }

  Future<void> clear() async {
    final result = await _clearCart(const NoParams());

    result.fold(
      (failure) => state = CartError(failure.message),
      (_) {},
    );
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
