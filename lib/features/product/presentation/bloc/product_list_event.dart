import 'package:equatable/equatable.dart';

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
