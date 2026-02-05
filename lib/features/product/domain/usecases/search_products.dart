import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

@lazySingleton
class SearchProducts {
  SearchProducts(this.repository);

  final ProductRepository repository;

  Future<List<Product>> call(SearchProductsParams params) {
    return repository.searchProducts(params.query);
  }
}

class SearchProductsParams extends Equatable {
  const SearchProductsParams({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}
