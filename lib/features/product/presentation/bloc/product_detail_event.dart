import 'package:equatable/equatable.dart';

sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailFetched extends ProductDetailEvent {
  const ProductDetailFetched(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
