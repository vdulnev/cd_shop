import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';

/// Use case to get the current cart
class GetCart extends UseCase<Cart, NoParams> {
  GetCart(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, Cart>> call(NoParams params) {
    return _repository.getCart();
  }
}
