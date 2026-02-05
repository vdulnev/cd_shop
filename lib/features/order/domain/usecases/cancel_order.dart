import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';

/// Use case for cancelling an order
abstract interface class CancelOrder implements UseCase<void, String> {}

@LazySingleton(as: CancelOrder)
class CancelOrderImpl implements CancelOrder {
  CancelOrderImpl(this.repository);

  final OrderRepository repository;

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.cancelOrder(params);
  }
}
