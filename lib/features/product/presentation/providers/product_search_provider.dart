import 'dart:async';

import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/presentation/providers/product_search_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductSearchNotifier extends Notifier<ProductSearchState> {
  late final SearchProducts _searchProducts;
  Timer? _debounce;
  int _searchToken = 0;

  @override
  ProductSearchState build() {
    _searchProducts = sl<SearchProducts>();
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return const ProductSearchInitial();
  }

  void updateQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const ProductSearchInitial();
      _debounce?.cancel();
      return;
    }

    _debounce?.cancel();
    final token = ++_searchToken;
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      state = const ProductSearchLoading();
      try {
        final products = await _searchProducts(
          SearchProductsParams(query: trimmed),
        );
        if (token != _searchToken) return;
        state = ProductSearchLoaded(products: products, query: trimmed);
      } catch (error) {
        if (token != _searchToken) return;
        state = const ProductSearchInitial();
      }
    });
  }

  void clear() {
    state = const ProductSearchInitial();
    _debounce?.cancel();
  }
}

final productSearchProvider = NotifierProvider<ProductSearchNotifier, ProductSearchState>(
  ProductSearchNotifier.new,
);
