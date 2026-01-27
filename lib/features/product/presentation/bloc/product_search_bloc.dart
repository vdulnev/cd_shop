import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:cd_shop/features/product/domain/usecases/search_products.dart';

import 'product_search_event.dart';
import 'product_search_state.dart';

export 'product_search_event.dart';
export 'product_search_state.dart';

class ProductSearchBloc extends Bloc<ProductSearchEvent, ProductSearchState> {
  ProductSearchBloc({required SearchProducts searchProducts})
      : _searchProducts = searchProducts,
        super(const ProductSearchInitial()) {
    on<ProductSearchQueryChanged>(
      _onQueryChanged,
      transformer: (events, mapper) =>
          events.debounce(const Duration(milliseconds: 300)).switchMap(mapper),
    );
    on<ProductSearchCleared>(_onCleared);
  }

  final SearchProducts _searchProducts;

  Future<void> _onQueryChanged(
    ProductSearchQueryChanged event,
    Emitter<ProductSearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(const ProductSearchInitial());
      return;
    }

    emit(const ProductSearchLoading());

    final result = await _searchProducts(SearchProductsParams(query: query));

    result.fold(
      (failure) => emit(ProductSearchError(failure.message)),
      (products) => emit(ProductSearchLoaded(products: products, query: query)),
    );
  }

  void _onCleared(
    ProductSearchCleared event,
    Emitter<ProductSearchState> emit,
  ) {
    emit(const ProductSearchInitial());
  }
}
