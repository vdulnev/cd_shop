import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_search_bloc.dart';

class MockSearchProducts extends Mock implements SearchProducts {}

class _FakeParams extends Fake implements SearchProductsParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeParams());
  });

  group('ProductSearchBloc', () {
    late MockSearchProducts mockSearchProducts;
    late ProductSearchBloc bloc;

    setUp(() {
      mockSearchProducts = MockSearchProducts();
      bloc = ProductSearchBloc(searchProducts: mockSearchProducts);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is ProductSearchInitial', () {
      expect(bloc.state, isA<ProductSearchInitial>());
    });

    blocTest<ProductSearchBloc, ProductSearchState>(
      'emits [Loading, Loaded] on successful search',
      build: () {
        when(() => mockSearchProducts(any(that: isA<SearchProductsParams>()))).thenAnswer(
          (_) async => const Right(<Product>[
            Product(
              id: '1',
              title: 'Abbey Road',
              artist: 'The Beatles',
              description: 'Classic album',
              price: 19.99,
              genre: ProductGenre.rock,
            ),
          ]),
        );
        return bloc;
      },
      act: (b) => b.add(const ProductSearchQueryChanged('beatles')),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        isA<ProductSearchLoading>(),
        isA<ProductSearchLoaded>().having((s) => s.query, 'query', 'beatles'),
      ],
      verify: (_) {
        verify(() => mockSearchProducts(const SearchProductsParams(query: 'beatles'))).called(1);
      },
    );

    blocTest<ProductSearchBloc, ProductSearchState>(
      'emits [Loading, Error] on failed search',
      build: () {
        when(() => mockSearchProducts(any(that: isA<SearchProductsParams>()))).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'oops')),
        );
        return bloc;
      },
      act: (b) => b.add(const ProductSearchQueryChanged('error')),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        isA<ProductSearchLoading>(),
        isA<ProductSearchError>().having((e) => e.message, 'message', 'oops'),
      ],
    );

    blocTest<ProductSearchBloc, ProductSearchState>(
      'emits nothing when query is empty',
      build: () => bloc,
      act: (b) => b.add(const ProductSearchQueryChanged('   ')),
      expect: () => [],
    );
  });
}
