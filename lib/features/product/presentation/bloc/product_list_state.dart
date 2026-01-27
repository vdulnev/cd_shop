import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';

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
// No explicit error state; errors are surfaced via app events/snackbars
