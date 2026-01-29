import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Abstract repository interface for Product feature
///
/// This interface defines the contract for data operations.
/// Implementations can be swapped for testing or different data sources.
abstract class ProductRepository {
  /// Get all products with optional filtering
  Future<List<Product>> getProducts({
    ProductGenre? genre,
    String? searchQuery,
    int? limit,
    int? offset,
  });

  /// Get a single product by ID
  Future<Product?> getProductById(String id);

  /// Search products by query string
  Future<List<Product>> searchProducts(String query);

  /// Get products by genre
  Future<List<Product>> getProductsByGenre(ProductGenre genre);

  /// Get featured/recommended products
  Future<List<Product>> getFeaturedProducts();

  /// Watch products for real-time updates
  Stream<List<Product>> watchProducts();

}
