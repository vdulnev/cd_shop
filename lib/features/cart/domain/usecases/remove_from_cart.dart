import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';

/// Use case to remove a product from the cart
@lazySingleton
class RemoveFromCart extends UseCase<Cart, RemoveFromCartParams> {
  RemoveFromCart(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, Cart>> call(RemoveFromCartParams params) {
    return _repository.removeFromCart(params.productId);
  }
}

class RemoveFromCartParams extends Equatable {
  const RemoveFromCartParams({required this.productId});

  final String productId;

  @override
  List<Object?> get props => [productId];
}
