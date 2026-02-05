import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';

/// Use case to clear all items from the cart
@lazySingleton
class ClearCart extends UseCase<Cart, NoParams> {
  ClearCart(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, Cart>> call(NoParams params) {
    return _repository.clearCart();
  }
}
