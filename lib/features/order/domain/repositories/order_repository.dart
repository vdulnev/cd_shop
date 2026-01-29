import 'package:dartz/dartz.dart' hide Order;

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';

/// Repository interface for order operations
abstract class OrderRepository {
  /// Place a new order
  Future<Either<Failure, Order>> placeOrder(OrderRequest request);

  /// Get orders for a specific user
  Stream<List<Order>> watchUserOrders(String userId);

  /// Get a specific order by ID
  Future<Either<Failure, Order>> getOrderById(String orderId);

  /// Cancel an order
  Future<Either<Failure, void>> cancelOrder(String orderId);
}
