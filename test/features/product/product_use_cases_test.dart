import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/domain/usecases/watch_products.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
  });

  const tProduct = Product(
    id: '1',
    title: 'Test Product',
    artist: 'Test Artist',
    description: 'Description',
    price: 10.0,
    genre: ProductGenre.rock,
  );
  const tProducts = [tProduct];

  group('GetProducts', () {
    test('should get products from the repository', () async {
      // Arrange
      when(
        () => mockProductRepository.getProducts(),
      ).thenAnswer((_) async => tProducts);
      final usecase = GetProductsImpl(mockProductRepository);

      // Act
      final result = await usecase();

      // Assert
      expect(result, tProducts);
      verify(() => mockProductRepository.getProducts()).called(1);
      verifyNoMoreInteractions(mockProductRepository);
    });
  });

  group('GetProductById', () {
    test('should get product by id from the repository', () async {
      // Arrange
      const tId = '1';
      when(
        () => mockProductRepository.getProductById(any()),
      ).thenAnswer((_) async => tProduct);
      final usecase = GetProductByIdImpl(mockProductRepository);

      // Act
      final result = await usecase(const GetProductByIdParams(id: tId));

      // Assert
      expect(result, tProduct);
      verify(() => mockProductRepository.getProductById(tId)).called(1);
      verifyNoMoreInteractions(mockProductRepository);
    });
  });

  group('SearchProducts', () {
    test('should search products from the repository', () async {
      // Arrange
      const tQuery = 'test';
      when(
        () => mockProductRepository.searchProducts(any()),
      ).thenAnswer((_) async => tProducts);
      final usecase = SearchProductsImpl(mockProductRepository);

      // Act
      final result = await usecase(const SearchProductsParams(query: tQuery));

      // Assert
      expect(result, tProducts);
      verify(() => mockProductRepository.searchProducts(tQuery)).called(1);
      verifyNoMoreInteractions(mockProductRepository);
    });
  });

  group('WatchProducts', () {
    test('should watch products from the repository', () {
      // Arrange
      when(
        () => mockProductRepository.watchProducts(),
      ).thenAnswer((_) => Stream.value(tProducts));
      final usecase = WatchProductsImpl(mockProductRepository);

      // Act
      final result = usecase();

      // Assert
      expect(result, emits(tProducts));
      verify(() => mockProductRepository.watchProducts()).called(1);
      verifyNoMoreInteractions(mockProductRepository);
    });
  });
}
