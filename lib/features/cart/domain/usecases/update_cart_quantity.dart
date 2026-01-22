import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';

/// Use case to update the quantity of a cart item
class UpdateCartQuantity extends UseCase<Cart, UpdateCartQuantityParams> {
  UpdateCartQuantity(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, Cart>> call(UpdateCartQuantityParams params) {
    return _repository.updateQuantity(params.productId, params.quantity);
  }
}

class UpdateCartQuantityParams extends Equatable {
  const UpdateCartQuantityParams({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}
