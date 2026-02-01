// ignore_for_file: close_sinks
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cd_shop/core/models/analytics_event.dart';
import 'package:cd_shop/core/models/disposable.dart';
import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Firestore implementation of [ProductRepository].
class FirestoreProductRepositoryImpl
  with EventEmitterMixin, AnalyticsEventBusMixin
  implements ProductRepository, Disposable {
  FirestoreProductRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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

  @override
  Future<List<Product>> getProducts({
    ProductGenre? genre,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
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

    return products;
  }

  @override
  Future<Product?> getProductById(String id) async {
    final doc = await _productsRef.doc(id).get();
    if (!doc.exists) return null;
    final product = _documentToProduct(doc);
    emitAnalyticsEvent(ViewProductAnalyticsEvent(product: product));
    return product;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    emitAnalyticsEvent(SearchAnalyticsEvent(query: query));
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
    final snapshot = await _productsRef
        .where('isAvailable', isEqualTo: true)
        .limit(6)
        .get();
    return snapshot.docs.map(_documentToProduct).toList();
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map(_documentToProduct).toList();
    });
  }
  
  @override
  void dispose() {
    disposeEventEmitter();
    disposeAnalyticsEmitter();
  }
}
