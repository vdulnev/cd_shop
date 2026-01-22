import 'package:floor/floor.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Database entity for products
@Entity(tableName: 'products')
class ProductEntity {
  ProductEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.genre,
    this.releaseYear,
    required this.stockQuantity,
    required this.isAvailable,
  });

  /// Convert from domain entity to database entity
  factory ProductEntity.fromDomain(Product product) {
    return ProductEntity(
      id: product.id,
      title: product.title,
      artist: product.artist,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      genre: product.genre.name,
      releaseYear: product.releaseYear,
      stockQuantity: product.stockQuantity,
      isAvailable: product.isAvailable,
    );
  }

  @primaryKey
  final String id;

  final String title;
  final String artist;
  final String description;
  final double price;
  final String? imageUrl;
  final String genre; // Stored as string, converted to/from ProductGenre
  final int? releaseYear;
  final int stockQuantity;
  final bool isAvailable;

  /// Convert to domain entity
  Product toDomain() {
    return Product(
      id: id,
      title: title,
      artist: artist,
      description: description,
      price: price,
      imageUrl: imageUrl,
      genre: ProductGenre.values.firstWhere(
        (g) => g.name == genre,
        orElse: () => ProductGenre.rock,
      ),
      releaseYear: releaseYear,
      stockQuantity: stockQuantity,
      isAvailable: isAvailable,
    );
  }
}
