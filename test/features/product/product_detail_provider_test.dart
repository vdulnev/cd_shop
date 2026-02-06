import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/presentation/providers/product_detail_provider.dart';
import 'package:cd_shop/features/product/presentation/providers/product_detail_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cd_shop/core/error/failures.dart';

class MockGetProductById extends Mock implements GetProductById {}

class _FakeGetProductByIdParams extends Fake implements GetProductByIdParams {}

void main() {
  late MockGetProductById mockGetProductById;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(_FakeGetProductByIdParams());
  });

  setUp(() {
    mockGetProductById = MockGetProductById();
    sl.registerLazySingleton<GetProductById>(() => mockGetProductById);

    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
    sl.reset();
  });

  const tProductId = '1';
  const tProduct = Product(
    id: tProductId,
    title: 'Test Product',
    artist: 'Test Artist',
    description: 'Description',
    price: 10.0,
    genre: ProductGenre.rock,
  );

  test('initial state is ProductDetailLoading', () {
    // Arrange
    when(() => mockGetProductById(any())).thenAnswer((_) async => tProduct);

    // Act & Assert
    // We expect loading immediately upon subscription because build() triggers load
    expect(
      container.read(productDetailProvider(tProductId)),
      isA<ProductDetailLoading>(),
    );
  });

  test('emits [Loading, Loaded] when data is gotten successfully', () async {
    // Arrange
    when(() => mockGetProductById(any())).thenAnswer((_) async => tProduct);

    // Act
    final states = <ProductDetailState>[];
    container.listen(
      productDetailProvider(tProductId),
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    // Wait for the async build/_load to complete
    await Future.delayed(Duration.zero);

    // Assert
    expect(states, [
      isA<ProductDetailLoading>(),
      isA<ProductDetailLoaded>().having((s) => s.product, 'product', tProduct),
    ]);
    verify(
      () => mockGetProductById(const GetProductByIdParams(id: tProductId)),
    ).called(1);
  });

  test('emits [Loading, NotFound] when product returns null', () async {
    // Arrange
    when(() => mockGetProductById(any())).thenAnswer((_) async => null);

    // Act
    final states = <ProductDetailState>[];
    container.listen(
      productDetailProvider(tProductId),
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    // Wait for async load
    await Future.delayed(Duration.zero);

    // Assert
    expect(states, [isA<ProductDetailLoading>(), isA<ProductDetailNotFound>()]);
  });

  test('emits [Loading, Error] when getting data fails', () async {
    // Arrange
    when(() => mockGetProductById(any())).thenAnswer(
      (_) async => throw const ServerFailure(message: 'Server Error'),
    );

    // Act
    final states = <ProductDetailState>[];
    container.listen(
      productDetailProvider(tProductId),
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    await Future.delayed(Duration.zero);

    // Assert
    expect(states, [
      isA<ProductDetailLoading>(),
      isA<ProductDetailError>().having(
        (s) => s.message,
        'message',
        contains('Server Error'),
      ),
    ]);
  });
}
