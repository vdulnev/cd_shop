import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Abstract repository interface for Product feature
///
/// This interface defines the contract for data operations.
/// Implementations can be swapped for testing or different data sources.
abstract class ProductRepository {
  /// Get all products with optional filtering
  Future<Either<Failure, List<Product>>> getProducts({
    ProductGenre? genre,
    String? searchQuery,
    int? limit,
    int? offset,
  });

  /// Get a single product by ID
  Future<Either<Failure, Product>> getProductById(String id);

  /// Search products by query string
  Future<Either<Failure, List<Product>>> searchProducts(String query);

  /// Get products by genre
  Future<Either<Failure, List<Product>>> getProductsByGenre(ProductGenre genre);

  /// Get featured/recommended products
  Future<Either<Failure, List<Product>>> getFeaturedProducts();
}
