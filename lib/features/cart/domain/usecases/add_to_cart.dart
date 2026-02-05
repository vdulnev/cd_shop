import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Use case to add a product to the cart
@lazySingleton
class AddToCart extends UseCase<Cart, AddToCartParams> {
  AddToCart(this._repository);

  final CartRepository _repository;

  @override
  Future<Either<Failure, Cart>> call(AddToCartParams params) {
    return _repository.addToCart(params.product, quantity: params.quantity);
  }
}

class AddToCartParams extends Equatable {
  const AddToCartParams({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  @override
  List<Object?> get props => [product, quantity];
}
