import 'dart:async';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/domain/usecases/watch_products.dart';
import 'package:cd_shop/features/product/presentation/providers/product_list_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductListNotifier extends Notifier<ProductListState> {
  late final WatchProducts _watchProducts;
  late final GetProducts _getProducts;
  StreamSubscription? _subscription;

  @override
  ProductListState build() {
    _watchProducts = sl<WatchProducts>();
    _getProducts = sl<GetProducts>();
    _subscribe();
    return const ProductListInitial();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _watchProducts(const NoParams()).listen(
      (products) {
        state = ProductListLoaded(products);
      },
      onError: (error) {
        state = const ProductListInitial();
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  Future<void> refresh() async {
    state = const ProductListLoading();
    try {
      final products = await _getProducts();
      state = ProductListLoaded(products);
    } catch (error) {
      state = const ProductListInitial();
    }
  }
}

final productListProvider =
    NotifierProvider<ProductListNotifier, ProductListState>(
  ProductListNotifier.new,
);
