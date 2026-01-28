import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/cart/domain/usecases/watch_cart.dart';
import 'package:cd_shop/features/cart/presentation/providers/cart_state.dart';
import 'package:cd_shop/injection_container.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier({
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
    _subscribe();
  }

  final AddToCart _addToCart;
  final RemoveFromCart _removeFromCart;
  final UpdateCartQuantity _updateCartQuantity;
  final ClearCart _clearCart;
  final WatchCart _watchCart;

  void _subscribe() {
    state = const CartLoading();
    _watchCart().listen((cart) {
      state = CartLoaded(cart);
    });
  }

  Future<void> addToCart(AddToCartParams params) async {
    final result = await _addToCart(params);
    result.fold(
      (failure) => state = CartError(failure.message),
      (_) {},
    );
  }

  Future<void> removeFromCart(RemoveFromCartParams params) async {
    final result = await _removeFromCart(params);
    result.fold(
      (failure) => state = CartError(failure.message),
      (_) {},
    );
  }

  Future<void> updateQuantity(UpdateCartQuantityParams params) async {
    final result = await _updateCartQuantity(params);
    result.fold(
      (failure) => state = CartError(failure.message),
      (_) {},
    );
  }

  Future<void> clearCart(NoParams params) async {
    final result = await _clearCart(params);
    result.fold(
      (failure) => state = CartError(failure.message),
      (_) {},
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(
    addToCart: sl<AddToCart>(),
    removeFromCart: sl<RemoveFromCart>(),
    updateCartQuantity: sl<UpdateCartQuantity>(),
    clearCart: sl<ClearCart>(),
    watchCart: sl<WatchCart>(),
  );
});
