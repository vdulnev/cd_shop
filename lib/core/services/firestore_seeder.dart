// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cd_shop/features/product/data/datasources/product_mock_datasource.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Utility to seed Firestore with initial data.
///
/// Run this once during development to populate the products collection.
class FirestoreSeeder {
  FirestoreSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Seed products collection from mock data.
  ///
  /// Returns the number of products seeded.
  Future<int> seedProducts({bool overwrite = false}) async {
    final productsRef = _firestore.collection('products');

    // Check if already seeded
    if (!overwrite) {
      final existing = await productsRef.limit(1).get();
      if (existing.docs.isNotEmpty) {
        print('Products already exist. Use overwrite=true to reseed.');
        return 0;
      }
    }

    final products = ProductMockDataSource.getAll();
    final batch = _firestore.batch();

    for (final product in products) {
      final docRef = productsRef.doc(product.id);
      batch.set(docRef, _productToMap(product));
    }

    await batch.commit();
    print('Seeded ${products.length} products to Firestore.');
    return products.length;
  }

  /// Seed a single product.
  Future<void> seedProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(_productToMap(product));
  }

  /// Delete all products (use with caution!).
  Future<int> deleteAllProducts() async {
    final snapshot = await _firestore.collection('products').get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    print('Deleted ${snapshot.docs.length} products.');
    return snapshot.docs.length;
  }

  Map<String, dynamic> _productToMap(Product product) {
    return {
      'title': product.title,
      'artist': product.artist,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'genre': product.genre.name,
      'releaseYear': product.releaseYear,
      'stockQuantity': product.stockQuantity,
      'isAvailable': product.isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
