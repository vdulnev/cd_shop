import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Use case to get a product by its ID
class GetProductById implements UseCase<Product, GetProductByIdParams> {
  GetProductById(this.repository);

  final ProductRepository repository;

  @override
  Future<Either<Failure, Product>> call(GetProductByIdParams params) {
    return repository.getProductById(params.id);
  }
}

/// Parameters for GetProductById use case
class GetProductByIdParams extends Equatable {
  const GetProductByIdParams({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}
