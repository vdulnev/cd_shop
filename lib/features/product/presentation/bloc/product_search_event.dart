import 'package:equatable/equatable.dart';

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
