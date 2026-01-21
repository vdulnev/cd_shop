import 'package:equatable/equatable.dart';

/// Canonical set of product genres
enum ProductGenre {
  heavyMetal,
  hardRock,
  rock,
  electronicSynthPop,
  electronicAlternative,
  country,
  countryRock,
}

extension ProductGenreX on ProductGenre {
  String get label => switch (this) {
        ProductGenre.heavyMetal => 'Heavy Metal',
        ProductGenre.hardRock => 'Hard Rock',
        ProductGenre.rock => 'Rock',
        ProductGenre.electronicSynthPop => 'Electronic/Synth-pop',
        ProductGenre.electronicAlternative => 'Electronic/Alternative',
        ProductGenre.country => 'Country',
        ProductGenre.countryRock => 'Country/Rock',
      };
}

/// Product entity representing a CD product in the shop
class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.artist,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.genre,
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
  final ProductGenre genre;
  final int? releaseYear;
  final int stockQuantity;
  final bool isAvailable;

  bool get isInStock => stockQuantity > 0 && isAvailable;

  String get genreLabel => genre.label;

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
