import 'package:injectable/injectable.dart' hide Order;

import 'package:cd_shop/features/order/domain/entities/order.dart'
    as order_entities;
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';

/// Use case for watching user orders
abstract interface class WatchUserOrders {
  Stream<List<order_entities.Order>> call(String params);
}

@LazySingleton(as: WatchUserOrders)
class WatchUserOrdersImpl implements WatchUserOrders {
  WatchUserOrdersImpl(this.repository);

  final OrderRepository repository;

  @override
  Stream<List<order_entities.Order>> call(String params) {
    return repository.watchUserOrders(params);
  }
}
