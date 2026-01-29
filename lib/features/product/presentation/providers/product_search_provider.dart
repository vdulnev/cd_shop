import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/presentation/providers/product_search_state.dart';
import 'package:cd_shop/injection_container.dart';

class ProductSearchNotifier extends StateNotifier<ProductSearchState> {
  ProductSearchNotifier({
    required SearchProducts searchProducts,
  }) : _searchProducts = searchProducts,
       super(const ProductSearchInitial());

  final SearchProducts _searchProducts;
  Timer? _debounce;

  void updateQuery(String query) {
    final trimmed = query.trim();
    _debounce?.cancel();

    if (trimmed.isEmpty) {
      state = const ProductSearchInitial();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      state = const ProductSearchLoading();
      final products = await _searchProducts(
        SearchProductsParams(query: trimmed),
      );
      state = ProductSearchLoaded(products: products, query: trimmed);
    });
  }

  void clear() {
    _debounce?.cancel();
    state = const ProductSearchInitial();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final productSearchProvider =
    StateNotifierProvider.autoDispose<
      ProductSearchNotifier,
      ProductSearchState
    >((ref) {
      return ProductSearchNotifier(
        searchProducts: sl<SearchProducts>(),
      );
    });
