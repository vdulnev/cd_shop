import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Use case to get all products
class GetProducts {
  GetProducts(this.repository);

  final ProductRepository repository;

  Future<List<Product>> call() {
    return repository.getProducts();
  }
}
