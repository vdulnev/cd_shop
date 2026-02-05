import 'package:dartz/dartz.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';

/// Use case for placing a new order
abstract interface class PlaceOrder implements UseCase<Order, OrderRequest> {}

@LazySingleton(as: PlaceOrder)
class PlaceOrderImpl implements PlaceOrder {
  PlaceOrderImpl(this.repository);

  final OrderRepository repository;

  @override
  Future<Either<Failure, Order>> call(OrderRequest params) {
    return repository.placeOrder(params);
  }
}
