import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';

/// Use case to watch the cart stream
abstract interface class WatchCart {
  Stream<Cart> call();
}

@LazySingleton(as: WatchCart)
class WatchCartImpl implements WatchCart {
  WatchCartImpl(this._repository);

  final CartRepository _repository;

  @override
  Stream<Cart> call() => _repository.watchCart();
}
