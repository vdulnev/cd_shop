import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_event.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_state.dart';

/// BLoC for managing product list state
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({
    required this.getProducts,
  }) : super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
  }

  final GetProducts getProducts;

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());

    final result = await getProducts(const NoParams());

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    // Keep showing current products while refreshing
    final currentState = state;
    if (currentState is ProductLoaded) {
      emit(ProductLoaded(products: currentState.products, isRefreshing: true));
    }

    final result = await getProducts(const NoParams());

    result.fold(
      (failure) => emit(ProductError(message: failure.message)),
      (products) => emit(ProductLoaded(products: products)),
    );
  }
}
