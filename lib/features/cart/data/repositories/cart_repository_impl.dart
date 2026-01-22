import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// In-memory implementation of CartRepository
///
/// Uses a simple in-memory map to store cart items.
/// In a real app, this would persist to local storage or a backend.
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl();

  /// In-memory storage: productId -> CartItem
  final Map<String, CartItem> _cartItems = {};

  @override
  Future<Either<Failure, Cart>> getCart() async {
    try {
      return Right(Cart(items: _cartItems.values.toList()));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to load cart'));
    }
  }

  @override
  Future<Either<Failure, Cart>> addToCart(
    Product product, {
    int quantity = 1,
  }) async {
    try {
      final existingItem = _cartItems[product.id];

      if (existingItem != null) {
        // Update quantity if item already exists
        _cartItems[product.id] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        );
      } else {
        // Add new item
        _cartItems[product.id] = CartItem(
          product: product,
          quantity: quantity,
        );
      }

      return Right(Cart(items: _cartItems.values.toList()));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to add item to cart'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(String productId) async {
    try {
      _cartItems.remove(productId);
      return Right(Cart(items: _cartItems.values.toList()));
    } catch (e) {
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
      final existingItem = _cartItems[productId];

      if (existingItem == null) {
        return const Left(NotFoundFailure(message: 'Item not found in cart'));
      }

      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        _cartItems.remove(productId);
      } else {
        _cartItems[productId] = existingItem.copyWith(quantity: quantity);
      }

      return Right(Cart(items: _cartItems.values.toList()));
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to update cart item'));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart() async {
    try {
      _cartItems.clear();
      return const Right(Cart());
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to clear cart'));
    }
  }
}
