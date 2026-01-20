import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Mock data source providing sample CD products
class ProductMockDataSource {
  ProductMockDataSource._();

  static const List<Product> products = [
    // Dio
    Product(
      id: 'dio-001',
      title: 'Holy Diver',
      artist: 'Dio',
      description:
          'Debut studio album by American heavy metal band Dio, released in 1983. Features iconic tracks and powerful vocals from Ronnie James Dio.',
      price: 14.99,
      genre: 'Heavy Metal',
      releaseYear: 1983,
      stockQuantity: 15,
    ),
    Product(
      id: 'dio-002',
      title: 'The Last in Line',
      artist: 'Dio',
      description:
          'Second studio album by Dio, released in 1984. A classic of the heavy metal genre.',
      price: 13.99,
      genre: 'Heavy Metal',
      releaseYear: 1984,
      stockQuantity: 8,
    ),

    // Scorpions
    Product(
      id: 'scorp-001',
      title: 'Blackout',
      artist: 'Scorpions',
      description:
          'Eighth studio album by German rock band Scorpions, released in 1982. A landmark hard rock album.',
      price: 12.99,
      genre: 'Hard Rock',
      releaseYear: 1982,
      stockQuantity: 12,
    ),
    Product(
      id: 'scorp-002',
      title: 'Love at First Sting',
      artist: 'Scorpions',
      description:
          'Ninth studio album by Scorpions, released in 1984. Their most commercially successful album worldwide.',
      price: 14.99,
      genre: 'Hard Rock',
      releaseYear: 1984,
      stockQuantity: 20,
    ),
    Product(
      id: 'scorp-003',
      title: 'Crazy World',
      artist: 'Scorpions',
      description:
          'Twelfth studio album by Scorpions, released in 1990. Features their global hit ballad.',
      price: 11.99,
      genre: 'Hard Rock',
      releaseYear: 1990,
      stockQuantity: 25,
    ),

    // Dire Straits
    Product(
      id: 'ds-001',
      title: 'Brothers in Arms',
      artist: 'Dire Straits',
      description:
          'Fifth studio album by British rock band Dire Straits, released in 1985. One of the best-selling albums worldwide.',
      price: 15.99,
      genre: 'Rock',
      releaseYear: 1985,
      stockQuantity: 30,
    ),
    Product(
      id: 'ds-002',
      title: 'Love Over Gold',
      artist: 'Dire Straits',
      description:
          'Fourth studio album by Dire Straits, released in 1982. Known for its extended compositions.',
      price: 13.99,
      genre: 'Rock',
      releaseYear: 1982,
      stockQuantity: 10,
    ),
    Product(
      id: 'ds-003',
      title: 'Making Movies',
      artist: 'Dire Straits',
      description:
          'Third studio album by Dire Straits, released in 1980. A critical and commercial success.',
      price: 12.99,
      genre: 'Rock',
      releaseYear: 1980,
      stockQuantity: 7,
    ),

    // Depeche Mode
    Product(
      id: 'dm-001',
      title: 'Violator',
      artist: 'Depeche Mode',
      description:
          'Seventh studio album by English electronic band Depeche Mode, released in 1990. Their most successful album.',
      price: 14.99,
      genre: 'Electronic/Synth-pop',
      releaseYear: 1990,
      stockQuantity: 18,
    ),
    Product(
      id: 'dm-002',
      title: 'Music for the Masses',
      artist: 'Depeche Mode',
      description:
          'Sixth studio album by Depeche Mode, released in 1987. Marked their breakthrough in the United States.',
      price: 13.99,
      genre: 'Electronic/Synth-pop',
      releaseYear: 1987,
      stockQuantity: 14,
    ),
    Product(
      id: 'dm-003',
      title: 'Songs of Faith and Devotion',
      artist: 'Depeche Mode',
      description:
          'Eighth studio album by Depeche Mode, released in 1993. Features a darker, more guitar-driven sound.',
      price: 12.99,
      genre: 'Electronic/Alternative',
      releaseYear: 1993,
      stockQuantity: 11,
    ),

    // Johnny Cash
    Product(
      id: 'jc-001',
      title: 'At Folsom Prison',
      artist: 'Johnny Cash',
      description:
          'Live album by Johnny Cash, recorded in 1968 at Folsom State Prison. A landmark in country and rock music.',
      price: 16.99,
      genre: 'Country',
      releaseYear: 1968,
      stockQuantity: 22,
    ),
    Product(
      id: 'jc-002',
      title: 'American IV: The Man Comes Around',
      artist: 'Johnny Cash',
      description:
          'Fourth album in the American Recordings series, released in 2002. His final album released during his lifetime.',
      price: 15.99,
      genre: 'Country/Rock',
      releaseYear: 2002,
      stockQuantity: 16,
    ),
    Product(
      id: 'jc-003',
      title: 'At San Quentin',
      artist: 'Johnny Cash',
      description:
          'Live album recorded in 1969 at San Quentin State Prison. Follow-up to the successful Folsom Prison album.',
      price: 14.99,
      genre: 'Country',
      releaseYear: 1969,
      stockQuantity: 9,
    ),

    // Iron Maiden
    Product(
      id: 'im-001',
      title: 'The Number of the Beast',
      artist: 'Iron Maiden',
      description:
          'Third studio album by British heavy metal band Iron Maiden, released in 1982. Considered a classic of the genre.',
      price: 14.99,
      genre: 'Heavy Metal',
      releaseYear: 1982,
      stockQuantity: 19,
    ),
    Product(
      id: 'im-002',
      title: 'Powerslave',
      artist: 'Iron Maiden',
      description:
          'Fifth studio album by Iron Maiden, released in 1984. Features Egyptian-themed artwork and epic compositions.',
      price: 13.99,
      genre: 'Heavy Metal',
      releaseYear: 1984,
      stockQuantity: 13,
    ),

    // Black Sabbath
    Product(
      id: 'bs-001',
      title: 'Paranoid',
      artist: 'Black Sabbath',
      description:
          'Second studio album by English rock band Black Sabbath, released in 1970. Pioneering heavy metal album.',
      price: 15.99,
      genre: 'Heavy Metal',
      releaseYear: 1970,
      stockQuantity: 17,
    ),
    Product(
      id: 'bs-002',
      title: 'Master of Reality',
      artist: 'Black Sabbath',
      description:
          'Third studio album by Black Sabbath, released in 1971. Influential in the development of doom metal.',
      price: 14.99,
      genre: 'Heavy Metal',
      releaseYear: 1971,
      stockQuantity: 6,
    ),

    // Deep Purple
    Product(
      id: 'dp-001',
      title: 'Machine Head',
      artist: 'Deep Purple',
      description:
          'Sixth studio album by English rock band Deep Purple, released in 1972. Features iconic hard rock tracks.',
      price: 13.99,
      genre: 'Hard Rock',
      releaseYear: 1972,
      stockQuantity: 21,
    ),
    Product(
      id: 'dp-002',
      title: 'Made in Japan',
      artist: 'Deep Purple',
      description:
          'Live album by Deep Purple, recorded in 1972. Considered one of the greatest live rock albums.',
      price: 16.99,
      genre: 'Hard Rock',
      releaseYear: 1972,
      stockQuantity: 8,
    ),
  ];

  /// Get all products
  static List<Product> getAll() => products;

  /// Get product by ID
  static Product? getById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get products by artist
  static List<Product> getByArtist(String artist) {
    return products
        .where((p) => p.artist.toLowerCase().contains(artist.toLowerCase()))
        .toList();
  }

  /// Get products by genre
  static List<Product> getByGenre(String genre) {
    return products
        .where((p) =>
            p.genre?.toLowerCase().contains(genre.toLowerCase()) ?? false)
        .toList();
  }

  /// Search products by query
  static List<Product> search(String query) {
    final q = query.toLowerCase();
    return products
        .where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.artist.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q))
        .toList();
  }
}
