import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Base class for all product states
sealed class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// Loading state while fetching products
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// State when products are successfully loaded
class ProductLoaded extends ProductState {
  const ProductLoaded({
    required this.products,
    this.isRefreshing = false,
  });

  final List<Product> products;
  final bool isRefreshing;

  @override
  List<Object?> get props => [products, isRefreshing];

  ProductLoaded copyWith({
    List<Product>? products,
    bool? isRefreshing,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// State when an error occurs
class ProductError extends ProductState {
  const ProductError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
