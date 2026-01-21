import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/usecases/search_products.dart';

// Events
sealed class ProductSearchEvent extends Equatable {
  const ProductSearchEvent();

  @override
  List<Object?> get props => [];
}

class ProductSearchQueryChanged extends ProductSearchEvent {
  const ProductSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ProductSearchCleared extends ProductSearchEvent {
  const ProductSearchCleared();
}

// States
sealed class ProductSearchState extends Equatable {
  const ProductSearchState();

  @override
  List<Object?> get props => [];
}

class ProductSearchInitial extends ProductSearchState {
  const ProductSearchInitial();
}

class ProductSearchLoading extends ProductSearchState {
  const ProductSearchLoading();
}

class ProductSearchLoaded extends ProductSearchState {
  const ProductSearchLoaded({
    required this.products,
    required this.query,
  });

  final List<Product> products;
  final String query;

  @override
  List<Object?> get props => [products, query];
}

class ProductSearchError extends ProductSearchState {
  const ProductSearchError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc
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
