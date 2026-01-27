import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';

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
// No explicit error state; errors are surfaced via app events/snackbars
