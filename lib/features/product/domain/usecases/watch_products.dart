import 'package:injectable/injectable.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Use case to watch products stream
abstract interface class WatchProducts {
  Stream<List<Product>> call();
}

@LazySingleton(as: WatchProducts)
class WatchProductsImpl implements WatchProducts {
  WatchProductsImpl(this._repository);

  final ProductRepository _repository;

  @override
  Stream<List<Product>> call() {
    return _repository.watchProducts();
  }
}
