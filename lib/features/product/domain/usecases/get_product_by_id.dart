import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Use case to get a product by its ID
@lazySingleton
class GetProductById {
  GetProductById(this.repository);

  final ProductRepository repository;

  Future<Product?> call(GetProductByIdParams params) {
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
