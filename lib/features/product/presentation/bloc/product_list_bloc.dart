import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';

// Events
sealed class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

class ProductListFetched extends ProductListEvent {
  const ProductListFetched();
}

class ProductListRefreshed extends ProductListEvent {
  const ProductListRefreshed();
}

// States
sealed class ProductListState extends Equatable {
  const ProductListState();

  @override
  List<Object?> get props => [];
}

class ProductListInitial extends ProductListState {
  const ProductListInitial();
}

class ProductListLoading extends ProductListState {
  const ProductListLoading();
}

class ProductListLoaded extends ProductListState {
  const ProductListLoaded(this.products);

  final List<Product> products;

  @override
  List<Object?> get props => [products];
}

class ProductListError extends ProductListState {
  const ProductListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// Bloc
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
