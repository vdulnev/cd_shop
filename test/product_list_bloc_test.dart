import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_list_bloc.dart';

class MockGetProducts extends Mock implements GetProducts {}

void main() {
  group('ProductListBloc', () {
    late MockGetProducts mockGetProducts;

    setUp(() {
      mockGetProducts = MockGetProducts();
    });

    blocTest<ProductListBloc, ProductListState>(
      'emits [Loading, Loaded] when ProductListFetched succeeds',
      build: () {
        when(() => mockGetProducts(const NoParams())).thenAnswer(
          (_) async => const Right(<Product>[
            Product(
              id: '1',
              title: 'Kind of Blue',
              artist: 'Miles Davis',
              description: 'Jazz classic',
              price: 14.99,
              genre: ProductGenre.rock,
            ),
          ]),
        );
        return ProductListBloc(getProducts: mockGetProducts);
      },
      act: (b) => b.add(const ProductListFetched()),
      expect: () => [
        isA<ProductListLoading>(),
        isA<ProductListLoaded>().having((s) => s.products.length, 'count', 1),
      ],
      verify: (_) {
        verify(() => mockGetProducts(const NoParams())).called(1);
      },
    );

    blocTest<ProductListBloc, ProductListState>(
      'emits [Loaded] when ProductListRefreshed succeeds (without loading)',
      build: () {
        when(() => mockGetProducts(const NoParams())).thenAnswer(
          (_) async => const Right(<Product>[
            Product(
              id: '2',
              title: 'The Dark Side of the Moon',
              artist: 'Pink Floyd',
              description: 'Progressive rock masterpiece',
              price: 21.99,
              genre: ProductGenre.rock,
            ),
          ]),
        );
        return ProductListBloc(getProducts: mockGetProducts);
      },
      act: (b) => b.add(const ProductListRefreshed()),
      expect: () => [
        isA<ProductListLoaded>().having((s) => s.products.first.id, 'first.id', '2'),
      ],
    );

    blocTest<ProductListBloc, ProductListState>(
      'emits [Loading, Error] when ProductListFetched fails',
      build: () {
        when(() => mockGetProducts(const NoParams())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'load failed')),
        );
        return ProductListBloc(getProducts: mockGetProducts);
      },
      act: (b) => b.add(const ProductListFetched()),
      expect: () => [
        isA<ProductListLoading>(),
        isA<ProductListError>().having((e) => e.message, 'message', 'load failed'),
      ],
    );
  });
}
