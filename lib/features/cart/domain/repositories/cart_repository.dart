import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Abstract repository interface for Cart feature
///
/// This interface defines the contract for cart data operations.
/// Implementations can be swapped for testing or different data sources.
abstract class CartRepository {
  /// Get the current cart
  Future<Either<Failure, Cart>> getCart();

  /// Add a product to the cart or increase quantity if already exists
  Future<Either<Failure, Cart>> addToCart(Product product, {int quantity = 1});

  /// Remove a product from the cart entirely
  Future<Either<Failure, Cart>> removeFromCart(String productId);

  /// Update the quantity of a cart item
  Future<Either<Failure, Cart>> updateQuantity(String productId, int quantity);

  /// Clear all items from the cart
  Future<Either<Failure, Cart>> clearCart();
}
