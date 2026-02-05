import 'package:injectable/injectable.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Use case to watch products in real-time
@lazySingleton
class WatchProducts extends StreamUseCase<List<Product>, NoParams> {
  WatchProducts(this._repository);

  final ProductRepository _repository;

  @override
  Stream<List<Product>> call(NoParams params) {
    return _repository.watchProducts();
  }
}
