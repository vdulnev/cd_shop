import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';

/// Use case to watch the cart stream
class WatchCart {
  WatchCart(this._repository);

  final CartRepository _repository;

  Stream<Cart> call() => _repository.watchCart();
}
