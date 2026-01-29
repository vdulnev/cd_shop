import 'package:cd_shop/features/product/presentation/providers/product_search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/presentation/providers/product_search_provider.dart';

class MockSearchProducts extends Mock implements SearchProducts {}


class _FakeParams extends Fake implements SearchProductsParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeParams());
  });

  group('ProductSearchNotifier', () {
    late MockSearchProducts mockSearchProducts;
    late AnalyticsEventBus analyticsEventBus;
    late ProviderContainer container;

    setUp(() {
      mockSearchProducts = MockSearchProducts();
      analyticsEventBus = AnalyticsEventBus();
      container = ProviderContainer(
        overrides: [
          productSearchProvider.overrideWith((_) {
            return ProductSearchNotifier(
              searchProducts: mockSearchProducts,
              analyticsEventBus: analyticsEventBus,
            );
          }),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is ProductSearchInitial', () {
      expect(container.read(productSearchProvider), isA<ProductSearchInitial>());
    });

    test('emits [Initial, Loading, Loaded] on successful search', () async {
      when(() => mockSearchProducts(any(that: isA<SearchProductsParams>()))).thenAnswer(
        (_) async => const <Product>[
          Product(
            id: '1',
            title: 'Abbey Road',
            artist: 'The Beatles',
            description: 'Classic album',
            price: 19.99,
            genre: ProductGenre.rock,
          ),
        ],
      );

      final states = <ProductSearchState>[];
      final sub = container.listen(
        productSearchProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      container.read(productSearchProvider.notifier).updateQuery('beatles');
      await Future.delayed(const Duration(milliseconds: 350));

      expect(states, [
        isA<ProductSearchInitial>(),
        isA<ProductSearchLoading>(),
        isA<ProductSearchLoaded>().having((s) => s.query, 'query', 'beatles'),
      ]);

      sub.close();
      verify(() => mockSearchProducts(const SearchProductsParams(query: 'beatles'))).called(1);
    });

    test('emits only initial state when query is empty', () {
      final states = <ProductSearchState>[];
      final sub = container.listen(
        productSearchProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      container.read(productSearchProvider.notifier).updateQuery('   ');

      expect(states, everyElement(isA<ProductSearchInitial>()));
      expect(states.length, anyOf(1, 2));

      sub.close();
    });
  });
}
