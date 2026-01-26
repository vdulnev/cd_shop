import 'package:floor/floor.dart';

import 'package:cd_shop/core/database/entities/order_entity.dart';

@dao
abstract class OrderDao {
  @Query('SELECT * FROM orders WHERE userId = :userId ORDER BY orderDate DESC')
  Stream<List<OrderEntity>> watchOrdersByUserId(String userId);

  @Query('SELECT * FROM orders WHERE id = :orderId')
  Future<OrderEntity?> getOrderById(String orderId);

  @insert
  Future<void> insertOrder(OrderEntity order);

  @update
  Future<void> updateOrder(OrderEntity order);

  @Query('SELECT * FROM order_items WHERE orderId = :orderId')
  Future<List<OrderItemEntity>> getOrderItems(String orderId);

  @insert
  Future<void> insertOrderItems(List<OrderItemEntity> items);
}
