import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// In-memory implementation of CartRepository
///
/// Uses a simple in-memory map to store cart items.
/// In a real app, this would persist to local storage or a backend.
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl() : _cartSubject = BehaviorSubject<Cart>.seeded(const Cart());

  // ignore: close_sinks - singleton repository, lives for app lifetime
  final _eventController = StreamController<RepositoryEvent>.broadcast();

  // ignore: close_sinks - singleton repository, lives for app lifetime
  final BehaviorSubject<Cart> _cartSubject;

  @override
  Future<Either<Failure, Cart>> addToCart(
    Product product, {
    int quantity = 1,
  }) async {
    try {
      return Right(_updateCart((items) {
        final index = items.indexWhere((item) => item.product.id == product.id);
        if (index >= 0) {
          final existingItem = items[index];
          items[index] = existingItem.copyWith(
            quantity: existingItem.quantity + quantity,
          );
        } else {
          items.add(
            CartItem(
              product: product,
              quantity: quantity,
            ),
          );
        }

        _eventController.add(
          CartSuccessEvent(message: '${product.title} added to cart!'),
        );
      }));
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to add item to cart'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(String productId) async {
    try {
      return Right(_updateCart((items) {
        final removed = items.removeWhereMatching(productId);
        if (removed) {
          _eventController.add(
            const CartSuccessEvent(message: 'Item removed from cart'),
          );
        }
      }));
    } catch (_) {
      return const Left(
        CacheFailure(message: 'Failed to remove item from cart'),
      );
    }
  }

  @override
  Future<Either<Failure, Cart>> updateQuantity(
    String productId,
    int quantity,
  ) async {
    try {
      final index = _cartSubject.value.items.indexWhere(
        (item) => item.product.id == productId,
      );

      if (index == -1) {
        return const Left(NotFoundFailure(message: 'Item not found in cart'));
      }

      return Right(_updateCart((items) {
        if (quantity <= 0) {
          items.removeAt(index);
        } else {
          final existingItem = items[index];
          items[index] = existingItem.copyWith(quantity: quantity);
        }
      }));
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to update cart item'));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart() async {
    try {
      return Right(_updateCart((items) => items.clear()));
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to clear cart'));
    }
  }

  @override
  Stream<Cart> watchCart() => _cartSubject.stream;

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;

  Cart _updateCart(void Function(List<CartItem>) mutate) {
    final items = List<CartItem>.from(_cartSubject.value.items);
    mutate(items);
    final cart = Cart(items: items);
    _cartSubject.add(cart);
    return cart;
  }
}

extension on List<CartItem> {
  bool removeWhereMatching(String productId) {
    final originalLength = length;
    removeWhere((item) => item.product.id == productId);
    return length != originalLength;
  }
}
