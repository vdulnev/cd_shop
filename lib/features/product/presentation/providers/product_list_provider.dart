import 'package:cd_shop/features/product/domain/usecases/get_products.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/usecases/watch_products.dart';
import 'package:cd_shop/features/product/presentation/providers/product_list_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/legacy.dart';

class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier({
    required WatchProducts watchProducts,
    required GetProducts getProducts,
  }) : _watchProducts = watchProducts,
       _getProducts = getProducts,
       super(const ProductListInitial()) {
    _subscribe();
  }

  final WatchProducts _watchProducts;
  final GetProducts _getProducts;

  void _subscribe() {
    _watchProducts(const NoParams()).listen((products) {
      state = ProductListLoaded(products);
    });
  }

  Future<void> refresh() async {
    state = const ProductListLoading();
    final products = await _getProducts();
    state = ProductListLoaded(products);
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
      return ProductListNotifier(watchProducts: sl(), getProducts: sl());
    });
