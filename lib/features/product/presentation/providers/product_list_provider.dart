import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/usecases/watch_products.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_list_state.dart';
import 'package:cd_shop/injection_container.dart';

class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier({required WatchProducts watchProducts})
      : _watchProducts = watchProducts,
        super(const ProductListInitial()) {
    _subscribe();
  }

  final WatchProducts _watchProducts;

  void _subscribe() {
    _watchProducts(const NoParams()).listen(
      (products) {
        state = ProductListLoaded(products);
      },
      // No explicit error state; keep last good state and surface via app events
      onError: (error) {},
    );
  }

  Future<void> refresh() async {
    final previous = state;
    state = const ProductListLoading();
    try {
      final products = await _watchProducts(const NoParams()).first;
      state = ProductListLoaded(products);
    } catch (error) {
      // Restore previous state on error
      state = previous;
    }
  }
}

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(watchProducts: sl<WatchProducts>());
});
