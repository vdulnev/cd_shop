import 'dart:async';

import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/presentation/providers/product_list_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/usecases/watch_products.dart';
import 'package:cd_shop/features/product/presentation/providers/product_list_provider.dart';

class MockWatchProducts extends Mock implements WatchProducts {}
class MockGetProducts extends Mock implements GetProducts {}

void main() {
  late MockWatchProducts mockWatchProducts;
  late MockGetProducts mockGetProducts;
  late StreamController<List<Product>> controller;
  late ProviderContainer container;

  setUp(() {
    mockWatchProducts = MockWatchProducts();
    mockGetProducts = MockGetProducts();
    controller = StreamController<List<Product>>.broadcast();

    when(() => mockWatchProducts(const NoParams()))
        .thenAnswer((_) => controller.stream);

    container = ProviderContainer(
      overrides: [
        productListProvider.overrideWith((_) {
          return ProductListNotifier(watchProducts: mockWatchProducts, getProducts: mockGetProducts);
        }),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    controller.close();
  });

  test('initial state transitions to Loaded when stream emits', () async {
    final states = <ProductListState>[];
    final sub = container.listen(
      productListProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    controller.add(const [
      Product(
        id: '1',
        title: 'Kind of Blue',
        artist: 'Miles Davis',
        description: 'Jazz classic',
        price: 14.99,
        genre: ProductGenre.rock,
      ),
    ]);

    // Allow stream event to propagate
    await Future.delayed(Duration.zero);

    expect(states, [
      isA<ProductListInitial>(),
      isA<ProductListLoaded>().having((s) => s.products.length, 'count', 1),
    ]);

    sub.close();
  });

  test('refresh emits Loading then Loaded', () async {
    when(() => mockGetProducts()).thenAnswer(
      (_) async => const <Product>[
        Product(
          id: '2',
          title: 'The Dark Side of the Moon',
          artist: 'Pink Floyd',
          description: 'Progressive rock masterpiece',
          price: 21.99,
          genre: ProductGenre.rock,
        ),
      ],
    );

    final states = <ProductListState>[];
    final sub = container.listen(
      productListProvider,
      (previous, next) => states.add(next),
      fireImmediately: true,
    );

    await container.read(productListProvider.notifier).refresh();

    expect(states.length, greaterThanOrEqualTo(3));
    expect(states[0], isA<ProductListInitial>());
    expect(states[1], isA<ProductListLoading>());
    expect(states[2], isA<ProductListLoaded>()
        .having((s) => s.products.first.id, 'first.id', '2'));

    sub.close();
  });
}
