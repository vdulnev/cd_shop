import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Use case to get product details by ID
class GetProductDetails implements UseCase<Product, ProductDetailsParams> {
  GetProductDetails(this.repository);

  final ProductRepository repository;

  @override
  Future<Either<Failure, Product>> call(ProductDetailsParams params) {
    return repository.getProductById(params.productId);
  }
}

/// Parameters for GetProductDetails use case
class ProductDetailsParams extends Equatable {
  const ProductDetailsParams({required this.productId});

  final String productId;

  @override
  List<Object?> get props => [productId];
}
