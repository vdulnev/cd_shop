import 'package:equatable/equatable.dart';

/// Base class for all product events
sealed class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load products
class LoadProducts extends ProductEvent {
  const LoadProducts();
}

/// Event to refresh products
class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}

/// Event to search products
class SearchProducts extends ProductEvent {
  const SearchProducts({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to filter products by genre
class FilterByGenre extends ProductEvent {
  const FilterByGenre({required this.genre});

  final String genre;

  @override
  List<Object?> get props => [genre];
}
