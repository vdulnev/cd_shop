import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/product/data/datasources/product_mock_datasource.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Implementation of ProductRepository using mock data
class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? genre,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      // Simulate network delay
      await Future<void>.delayed(const Duration(milliseconds: 500));

      List<Product> results = ProductMockDataSource.getAll();

      if (genre != null) {
        results = results
            .where((p) =>
                p.genre?.toLowerCase().contains(genre.toLowerCase()) ?? false)
            .toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        results = ProductMockDataSource.search(searchQuery);
      }

      if (offset != null && offset > 0) {
        results = results.skip(offset).toList();
      }

      if (limit != null && limit > 0) {
        results = results.take(limit).toList();
      }

      return Right(results);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load products'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));

      final product = ProductMockDataSource.getById(id);

      if (product == null) {
        return const Left(NotFoundFailure(message: 'Product not found'));
      }

      return Right(product);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load product'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final results = ProductMockDataSource.search(query);
      return Right(results);
    } catch (e) {
      return const Left(ServerFailure(message: 'Search failed'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByGenre(
    String genre,
  ) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final results = ProductMockDataSource.getByGenre(genre);
      return Right(results);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load products'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getFeaturedProducts() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));

      // Return first 6 products as featured
      final results = ProductMockDataSource.getAll().take(6).toList();
      return Right(results);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load products'));
    }
  }
}
