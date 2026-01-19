import 'package:equatable/equatable.dart';

/// Product entity representing a CD product in the shop
class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.price,
    this.imageUrl,
    this.genre,
    this.releaseYear,
    this.stockQuantity = 0,
    this.isAvailable = true,
  });

  final String id;
  final String title;
  final String artist;
  final String description;
  final double price;
  final String? imageUrl;
  final String? genre;
  final int? releaseYear;
  final int stockQuantity;
  final bool isAvailable;

  bool get isInStock => stockQuantity > 0 && isAvailable;

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        description,
        price,
        imageUrl,
        genre,
        releaseYear,
        stockQuantity,
        isAvailable,
      ];
}
