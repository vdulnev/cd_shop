import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/database/daos/product_dao.dart';
import 'package:cd_shop/core/database/entities/product_entity.dart';
import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/product/data/datasources/product_mock_datasource.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Floor database implementation of ProductRepository
///
/// Persists products to SQLite using Floor.
/// Seeds database with mock data on first launch.
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductDao productDao,
  }) : _productDao = productDao;

  final ProductDao _productDao;
  bool _isInitialized = false;

  // ignore: close_sinks - singleton repository, lives for app lifetime
  final _eventController = StreamController<RepositoryEvent>.broadcast();

  /// Ensure database is seeded with mock data on first access
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    final count = await _productDao.getProductCount() ?? 0;
    if (count == 0) {
      // Seed database with mock data
      final mockProducts = ProductMockDataSource.getAll();
      final entities = mockProducts.map(ProductEntity.fromDomain).toList();
      await _productDao.insertProducts(entities);
    }

    _isInitialized = true;
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    ProductGenre? genre,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      await _ensureInitialized();

      List<ProductEntity> entities;

      if (genre != null) {
        entities = await _productDao.getProductsByGenre(genre.name);
      } else if (searchQuery != null && searchQuery.isNotEmpty) {
        entities = await _productDao.searchProducts('%$searchQuery%');
      } else {
        entities = await _productDao.getAllProducts();
      }

      List<Product> results = entities.map((e) => e.toDomain()).toList();

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
      await _ensureInitialized();

      final entity = await _productDao.getProductById(id);

      if (entity == null) {
        return const Left(NotFoundFailure(message: 'Product not found'));
      }

      return Right(entity.toDomain());
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load product'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      await _ensureInitialized();

      final entities = await _productDao.searchProducts('%$query%');
      final results = entities.map((e) => e.toDomain()).toList();

      return Right(results);
    } catch (e) {
      return const Left(ServerFailure(message: 'Search failed'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByGenre(
    ProductGenre genre,
  ) async {
    try {
      await _ensureInitialized();

      final entities = await _productDao.getProductsByGenre(genre.name);
      final results = entities.map((e) => e.toDomain()).toList();

      return Right(results);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load products'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getFeaturedProducts() async {
    try {
      await _ensureInitialized();

      final entities = await _productDao.getFeaturedProducts(6);
      final results = entities.map((e) => e.toDomain()).toList();

      return Right(results);
    } catch (e) {
      return const Left(ServerFailure(message: 'Failed to load products'));
    }
  }

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;
}
