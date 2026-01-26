import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart' as order_entities;
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';

/// Use case for watching user orders
class WatchUserOrders implements StreamUseCase<List<order_entities.Order>, String> {
  WatchUserOrders(this.repository);

  final OrderRepository repository;

  @override
  Stream<List<order_entities.Order>> call(String params) {
    return repository.watchUserOrders(params);
  }
}
