import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

class SearchProducts implements UseCase<List<Product>, SearchProductsParams> {
  SearchProducts(this.repository);

  final ProductRepository repository;

  @override
  Future<Either<Failure, List<Product>>> call(SearchProductsParams params) {
    return repository.searchProducts(params.query);
  }
}

class SearchProductsParams extends Equatable {
  const SearchProductsParams({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}
