import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Use case to get all products
/// Use case to get all products
abstract interface class GetProducts {
  Future<List<Product>> call();
}

@LazySingleton(as: GetProducts)
class GetProductsImpl implements GetProducts {
  GetProductsImpl(this.repository);

  final ProductRepository repository;

  @override
  Future<List<Product>> call() {
    return repository.getProducts();
  }
}
