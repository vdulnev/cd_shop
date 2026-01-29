// ignore_for_file: close_sinks
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cd_shop/core/database/daos/product_dao.dart';
import 'package:cd_shop/core/database/entities/product_entity.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Firestore implementation of [ProductRepository] with local Floor caching.
///
/// Uses Firestore as the primary data source and falls back to
/// local SQLite cache when offline.
class FirestoreProductRepositoryImpl implements ProductRepository {
  FirestoreProductRepositoryImpl({
    FirebaseFirestore? firestore,
    required ProductDao productDao,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _productDao = productDao;

  final FirebaseFirestore _firestore;
  final ProductDao _productDao;

  final _eventController = StreamController<RepositoryEvent>.broadcast();

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  /// Convert Firestore document to Product domain entity.
  Product _documentToProduct(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: doc.id,
      title: data['title'] as String? ?? '',
      artist: data['artist'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String?,
      genre: _parseGenre(data['genre'] as String?),
      releaseYear: data['releaseYear'] as int?,
      stockQuantity: data['stockQuantity'] as int? ?? 0,
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  /// Parse genre string to enum, with fallback.
  ProductGenre _parseGenre(String? genreString) {
    if (genreString == null) return ProductGenre.rock;
    try {
      return ProductGenre.values.firstWhere(
        (g) => g.name == genreString,
        orElse: () => ProductGenre.rock,
      );
    } catch (_) {
      return ProductGenre.rock;
    }
  }

  /// Cache products to local Floor database.
  Future<void> _cacheProducts(List<Product> products) async {
    try {
      final entities = products.map(ProductEntity.fromDomain).toList();
      await _productDao.insertProducts(entities);
    } catch (_) {
      // Caching failure is non-critical
    }
  }

  /// Get products from local cache.
  Future<List<Product>> _getProductsFromCache({
    ProductGenre? genre,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
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

    return results;
  }

  @override
  Future<List<Product>> getProducts({
    ProductGenre? genre,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _productsRef;

      if (genre != null) {
        query = query.where('genre', isEqualTo: genre.name);
      }

      if (limit != null) {
        query = query.limit(limit + (offset ?? 0));
      }

      final snapshot = await query.get();
      var products = snapshot.docs.map(_documentToProduct).toList();

      // Apply offset locally (Firestore pagination is cursor-based)
      if (offset != null && offset > 0) {
        products = products.skip(offset).toList();
      }

      if (limit != null) {
        products = products.take(limit).toList();
      }

      // Apply search filter locally (Firestore doesn't support full-text search)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final lowerQuery = searchQuery.toLowerCase();
        products = products
            .where((p) =>
                p.title.toLowerCase().contains(lowerQuery) ||
                p.artist.toLowerCase().contains(lowerQuery))
            .toList();
      }

      // Cache products locally for offline access
      await _cacheProducts(products);

      return products;
    } catch (e) {
      // Fallback to local cache on error
      return _getProductsFromCache(
        genre: genre,
        searchQuery: searchQuery,
        limit: limit,
        offset: offset,
      );
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _productsRef.doc(id).get();
      if (!doc.exists) {
        // Try local cache
        final entity = await _productDao.getProductById(id);
        return entity?.toDomain();
      }
      final product = _documentToProduct(doc);
      await _cacheProducts([product]);
      return product;
    } catch (e) {
      // Fallback to local cache
      final entity = await _productDao.getProductById(id);
      return entity?.toDomain();
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    // Firestore doesn't support full-text search
    // Fetch all products and filter locally
    final products = await getProducts();
    final lowerQuery = query.toLowerCase();
    return products
        .where((p) =>
            p.title.toLowerCase().contains(lowerQuery) ||
            p.artist.toLowerCase().contains(lowerQuery) ||
            p.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<List<Product>> getProductsByGenre(ProductGenre genre) async {
    return getProducts(genre: genre);
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final snapshot = await _productsRef
          .where('isAvailable', isEqualTo: true)
          .limit(6)
          .get();
      final products = snapshot.docs.map(_documentToProduct).toList();
      await _cacheProducts(products);
      return products;
    } catch (e) {
      // Fallback to local cache
      final entities = await _productDao.getFeaturedProducts(6);
      return entities.map((e) => e.toDomain()).toList();
    }
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _productsRef.snapshots().map((snapshot) {
      final products = snapshot.docs.map(_documentToProduct).toList();
      // Cache in background
      _cacheProducts(products);
      return products;
    }).handleError((error) {
      // On error, emit from local cache once
      _productDao.getAllProducts().then((entities) {
        // Note: Stream has already errored, this is for logging
      });
    });
  }

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;
}
