import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';

import 'product_list_event.dart';
import 'product_list_state.dart';

export 'product_list_event.dart';
export 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc({required GetProducts getProducts})
      : _getProducts = getProducts,
        super(const ProductListInitial()) {
    on<ProductListFetched>(_onFetched);
    on<ProductListRefreshed>(_onRefreshed);
  }

  final GetProducts _getProducts;

  Future<void> _onFetched(
    ProductListFetched event,
    Emitter<ProductListState> emit,
  ) async {
    emit(const ProductListLoading());
    await _fetchProducts(emit);
  }

  Future<void> _onRefreshed(
    ProductListRefreshed event,
    Emitter<ProductListState> emit,
  ) async {
    await _fetchProducts(emit);
  }

  Future<void> _fetchProducts(Emitter<ProductListState> emit) async {
    final result = await _getProducts(const NoParams());
    result.fold(
      (failure) => emit(ProductListError(failure.message)),
      (products) => emit(ProductListLoaded(products)),
    );
  }
}
