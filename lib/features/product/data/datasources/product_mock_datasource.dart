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
            genre: ProductGenre.heavyMetal,
      releaseYear: 1983,
      stockQuantity: 15,
      imageUrl:
          'https://coverartarchive.org/release-group/4e7b34de-0d87-356a-a3da-b21f769b7d4d/front',
    ),
    Product(
      id: 'dio-002',
      title: 'The Last in Line',
      artist: 'Dio',
      description:
          'Second studio album by Dio, released in 1984. A classic of the heavy metal genre.',
      price: 13.99,
            genre: ProductGenre.heavyMetal,
      releaseYear: 1984,
      stockQuantity: 8,
      imageUrl:
          'https://coverartarchive.org/release-group/798601d4-f28e-3835-b10c-1a00ecf773b8/front',
    ),

    // Scorpions
        Product(
      id: 'scorp-001',
      title: 'Blackout',
      artist: 'Scorpions',
      description:
          'Eighth studio album by German rock band Scorpions, released in 1982. A landmark hard rock album.',
      price: 12.99,
            genre: ProductGenre.hardRock,
      releaseYear: 1982,
      stockQuantity: 12,
      imageUrl:
          'https://coverartarchive.org/release-group/b00fbf7c-ebaf-3ec0-91d6-5eaad124d58f/front',
    ),
    Product(
      id: 'scorp-002',
      title: 'Love at First Sting',
      artist: 'Scorpions',
      description:
          'Ninth studio album by Scorpions, released in 1984. Their most commercially successful album worldwide.',
      price: 14.99,
            genre: ProductGenre.hardRock,
      releaseYear: 1984,
      stockQuantity: 20,
      imageUrl:
          'https://coverartarchive.org/release-group/f74b6e75-f11c-3230-a5f1-0305d623a0a6/front',
    ),
    Product(
      id: 'scorp-003',
      title: 'Crazy World',
      artist: 'Scorpions',
      description:
          'Twelfth studio album by Scorpions, released in 1990. Features their global hit ballad.',
      price: 11.99,
            genre: ProductGenre.hardRock,
      releaseYear: 1990,
      stockQuantity: 25,
      imageUrl:
          'https://coverartarchive.org/release-group/d8a27312-3b03-36a0-a184-49b032528c1d/front',
    ),

    // Dire Straits
        Product(
      id: 'ds-001',
      title: 'Brothers in Arms',
      artist: 'Dire Straits',
      description:
          'Fifth studio album by British rock band Dire Straits, released in 1985. One of the best-selling albums worldwide.',
      price: 15.99,
            genre: ProductGenre.rock,
      releaseYear: 1985,
      stockQuantity: 30,
      imageUrl:
          'https://coverartarchive.org/release-group/b02f651e-32a1-30ae-bc23-070b59170278/front',
    ),
    Product(
      id: 'ds-002',
      title: 'Love Over Gold',
      artist: 'Dire Straits',
      description:
          'Fourth studio album by Dire Straits, released in 1982. Known for its extended compositions.',
      price: 13.99,
            genre: ProductGenre.rock,
      releaseYear: 1982,
      stockQuantity: 10,
      imageUrl:
          'https://coverartarchive.org/release-group/935dde7e-8390-39fa-8e0d-1350db96bc3f/front',
    ),
    Product(
      id: 'ds-003',
      title: 'Making Movies',
      artist: 'Dire Straits',
      description:
          'Third studio album by Dire Straits, released in 1980. A critical and commercial success.',
      price: 12.99,
            genre: ProductGenre.rock,
      releaseYear: 1980,
      stockQuantity: 7,
      imageUrl:
          'https://coverartarchive.org/release-group/5b0a15ce-8aa9-323b-8fb6-02b657756ba9/front',
    ),

    // Depeche Mode
        Product(
      id: 'dm-001',
      title: 'Violator',
      artist: 'Depeche Mode',
      description:
          'Seventh studio album by English electronic band Depeche Mode, released in 1990. Their most successful album.',
      price: 14.99,
            genre: ProductGenre.electronicSynthPop,
      releaseYear: 1990,
      stockQuantity: 18,
      imageUrl:
          'https://coverartarchive.org/release-group/71f1482e-e63f-3b2c-811b-939f62708f2a/front',
    ),
    Product(
      id: 'dm-002',
      title: 'Music for the Masses',
      artist: 'Depeche Mode',
      description:
          'Sixth studio album by Depeche Mode, released in 1987. Marked their breakthrough in the United States.',
      price: 13.99,
            genre: ProductGenre.electronicSynthPop,
      releaseYear: 1987,
      stockQuantity: 14,
      imageUrl:
          'https://coverartarchive.org/release-group/e59021bd-1710-3c13-9449-b78560039592/front',
    ),
    Product(
      id: 'dm-003',
      title: 'Songs of Faith and Devotion',
      artist: 'Depeche Mode',
      description:
          'Eighth studio album by Depeche Mode, released in 1993. Features a darker, more guitar-driven sound.',
      price: 12.99,
            genre: ProductGenre.electronicAlternative,
      releaseYear: 1993,
      stockQuantity: 11,
      imageUrl:
          'https://coverartarchive.org/release-group/e171597d-e6d5-36c8-8d0e-63daf79796b8/front',
    ),

    // Johnny Cash
        Product(
      id: 'jc-001',
      title: 'At Folsom Prison',
      artist: 'Johnny Cash',
      description:
          'Live album by Johnny Cash, recorded in 1968 at Folsom State Prison. A landmark in country and rock music.',
      price: 16.99,
            genre: ProductGenre.country,
      releaseYear: 1968,
      stockQuantity: 22,
      imageUrl:
          'https://coverartarchive.org/release-group/6b4ea595-3378-3019-be5f-058412670791/front',
    ),
    Product(
      id: 'jc-002',
      title: 'American IV: The Man Comes Around',
      artist: 'Johnny Cash',
      description:
          'Fourth album in the American Recordings series, released in 2002. His final album released during his lifetime.',
      price: 15.99,
            genre: ProductGenre.countryRock,
      releaseYear: 2002,
      stockQuantity: 16,
      imageUrl:
          'https://coverartarchive.org/release-group/aca4ccc8-5d1b-361e-ab21-396b2c6d42d3/front',
    ),
    Product(
      id: 'jc-003',
      title: 'At San Quentin',
      artist: 'Johnny Cash',
      description:
          'Live album recorded in 1969 at San Quentin State Prison. Follow-up to the successful Folsom Prison album.',
      price: 14.99,
            genre: ProductGenre.country,
      releaseYear: 1969,
      stockQuantity: 9,
      imageUrl:
          'https://coverartarchive.org/release-group/50df1aa9-6c37-46da-90bd-140363ddf878/front',
    ),

    // Iron Maiden
        Product(
      id: 'im-001',
      title: 'The Number of the Beast',
      artist: 'Iron Maiden',
      description:
          'Third studio album by British heavy metal band Iron Maiden, released in 1982. Considered a classic of the genre.',
      price: 14.99,
            genre: ProductGenre.heavyMetal,
      releaseYear: 1982,
      stockQuantity: 19,
      imageUrl:
          'https://coverartarchive.org/release-group/4ebfe175-e7ed-34cd-8e91-67c7e4a53579/front',
    ),
    Product(
      id: 'im-002',
      title: 'Powerslave',
      artist: 'Iron Maiden',
      description:
          'Fifth studio album by Iron Maiden, released in 1984. Features Egyptian-themed artwork and epic compositions.',
      price: 13.99,
            genre: ProductGenre.heavyMetal,
      releaseYear: 1984,
      stockQuantity: 13,
      imageUrl:
          'https://coverartarchive.org/release-group/60a20bc8-acac-3cbb-99f9-ce458317233a/front',
    ),

    // Black Sabbath
        Product(
      id: 'bs-001',
      title: 'Paranoid',
      artist: 'Black Sabbath',
      description:
          'Second studio album by English rock band Black Sabbath, released in 1970. Pioneering heavy metal album.',
      price: 15.99,
            genre: ProductGenre.heavyMetal,
      releaseYear: 1970,
      stockQuantity: 17,
      imageUrl:
          'https://coverartarchive.org/release-group/cc053745-c447-3566-8f27-bed5438c9133/front',
    ),
    Product(
      id: 'bs-002',
      title: 'Master of Reality',
      artist: 'Black Sabbath',
      description:
          'Third studio album by Black Sabbath, released in 1971. Influential in the development of doom metal.',
      price: 14.99,
            genre: ProductGenre.heavyMetal,
      releaseYear: 1971,
      stockQuantity: 6,
      imageUrl:
          'https://coverartarchive.org/release-group/e51e9779-2edc-3b39-959c-299fdb5ed940/front',
    ),

    // Deep Purple
        Product(
      id: 'dp-001',
      title: 'Machine Head',
      artist: 'Deep Purple',
      description:
          'Sixth studio album by English rock band Deep Purple, released in 1972. Features iconic hard rock tracks.',
      price: 13.99,
            genre: ProductGenre.hardRock,
      releaseYear: 1972,
      stockQuantity: 21,
      imageUrl:
          'https://coverartarchive.org/release-group/d00243c5-adcf-3018-9aa7-1957d7a5a774/front',
    ),
    Product(
      id: 'dp-002',
      title: 'Made in Japan',
      artist: 'Deep Purple',
      description:
          'Live album by Deep Purple, recorded in 1972. Considered one of the greatest live rock albums.',
      price: 16.99,
            genre: ProductGenre.hardRock,
      releaseYear: 1972,
      stockQuantity: 8,
      imageUrl:
          'https://coverartarchive.org/release-group/afab893b-4284-37c3-bf74-0139773c8c6d/front',
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
    static List<Product> getByGenre(ProductGenre genre) {
        return products.where((p) => p.genre == genre).toList();
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
