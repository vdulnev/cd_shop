// ignore_for_file: close_sinks
import 'dart:async';

import 'package:dartz/dartz.dart' hide Order;
import 'package:uuid/uuid.dart';

import 'package:cd_shop/core/database/daos/address_dao.dart';
import 'package:cd_shop/core/database/daos/order_dao.dart';
import 'package:cd_shop/core/database/entities/order_entity.dart';
import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required this.orderDao,
    required this.addressDao,
  });

  final OrderDao orderDao;
  final AddressDao addressDao;
  final _eventController = StreamController<RepositoryEvent>.broadcast();
  final _uuid = const Uuid();

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;

  @override
  Future<Either<Failure, Order>> placeOrder(OrderRequest request) async {
    try {
      // Fetch the shipping address
      final addressEntity = await addressDao.getAddressById(request.shippingAddressId);
      if (addressEntity == null) {
        return const Left(NotFoundFailure(message: 'Shipping address not found'));
      }
      final shippingAddress = addressEntity.toDomain();

      // Calculate costs
      final subtotal = request.items.fold(0.0, (sum, item) => sum + item.totalPrice);
      const shippingCost = 5.99; // Fixed shipping cost
      final tax = subtotal * 0.08; // 8% tax
      final total = subtotal + shippingCost + tax;

      // Generate order ID
      final orderId = _uuid.v4();

      // Create order entity
      final orderEntity = OrderEntity(
        id: orderId,
        userId: request.userId,
        shippingAddressId: request.shippingAddressId,
        paymentMethod: request.paymentMethod.name,
        subtotal: subtotal,
        shippingCost: shippingCost,
        tax: tax,
        total: total,
        status: OrderStatus.pending.name,
        orderDate: DateTime.now().millisecondsSinceEpoch,
        estimatedDeliveryDate: DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
        notes: request.notes,
      );

      // Save order to database
      await orderDao.insertOrder(orderEntity);

      // Save order items
      final orderItems = request.items
          .map((item) => OrderItemEntity.fromCartItem(orderId, item))
          .toList();
      await orderDao.insertOrderItems(orderItems);

      // Create domain order object
      final order = Order(
        id: orderId,
        userId: request.userId,
        items: request.items,
        shippingAddress: shippingAddress,
        paymentMethod: request.paymentMethod,
        subtotal: subtotal,
        shippingCost: shippingCost,
        tax: tax,
        total: total,
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        estimatedDeliveryDate: DateTime.now().add(const Duration(days: 7)),
        notes: request.notes,
      );

      _eventController.add(
        const OrderSuccessEvent(message: 'Order placed successfully'),
      );

      return Right(order);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to place order'));
    }
  }

  @override
  Stream<List<Order>> watchUserOrders(String userId) {
    return orderDao.watchOrdersByUserId(userId).asyncMap((orderEntities) async {
      final orderFutures = orderEntities.map(_entityToDomain);
      final orders = await Future.wait(orderFutures);
      return orders.nonNulls.toList();
    });
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final orderEntity = await orderDao.getOrderById(orderId);
      if (orderEntity == null) {
        return const Left(NotFoundFailure(message: 'Order not found'));
      }

      final order = await _entityToDomain(orderEntity);
      if (order == null) {
        return const Left(CacheFailure(message: 'Failed to load order'));
      }

      return Right(order);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to load order'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      final orderEntity = await orderDao.getOrderById(orderId);
      if (orderEntity == null) {
        return const Left(NotFoundFailure(message: 'Order not found'));
      }

      final updatedOrder = OrderEntity(
        id: orderEntity.id,
        userId: orderEntity.userId,
        shippingAddressId: orderEntity.shippingAddressId,
        paymentMethod: orderEntity.paymentMethod,
        subtotal: orderEntity.subtotal,
        shippingCost: orderEntity.shippingCost,
        tax: orderEntity.tax,
        total: orderEntity.total,
        status: OrderStatus.cancelled.name,
        orderDate: orderEntity.orderDate,
        estimatedDeliveryDate: orderEntity.estimatedDeliveryDate,
        notes: orderEntity.notes,
      );

      await orderDao.updateOrder(updatedOrder);

      _eventController.add(
        const OrderSuccessEvent(message: 'Order cancelled successfully'),
      );

      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to cancel order'));
    }
  }

  /// Convert order entity to domain model
  Future<Order?> _entityToDomain(OrderEntity entity) async {
    try {
      // Fetch shipping address
      final addressEntity = await addressDao.getAddressById(entity.shippingAddressId);
      if (addressEntity == null) return null;

      // Fetch order items
      final orderItemEntities = await orderDao.getOrderItems(entity.id);

      // Convert order items to cart items
      final items = orderItemEntities.map((itemEntity) {
        final product = Product(
          id: itemEntity.productId,
          title: itemEntity.productTitle,
          artist: itemEntity.productArtist,
          description: '', // Not stored in order items
          price: itemEntity.productPrice,
          imageUrl: itemEntity.productImageUrl,
          genre: ProductGenre.rock, // Default genre
          stockQuantity: 0,
        );
        return CartItem(product: product, quantity: itemEntity.quantity);
      }).toList();

      return Order(
        id: entity.id,
        userId: entity.userId,
        items: items,
        shippingAddress: addressEntity.toDomain(),
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == entity.paymentMethod,
          orElse: () => PaymentMethod.creditCard,
        ),
        subtotal: entity.subtotal,
        shippingCost: entity.shippingCost,
        tax: entity.tax,
        total: entity.total,
        status: OrderStatus.values.firstWhere(
          (e) => e.name == entity.status,
          orElse: () => OrderStatus.pending,
        ),
        orderDate: DateTime.fromMillisecondsSinceEpoch(entity.orderDate),
        estimatedDeliveryDate: entity.estimatedDeliveryDate != null
            ? DateTime.fromMillisecondsSinceEpoch(entity.estimatedDeliveryDate!)
            : null,
        notes: entity.notes,
      );
    } catch (e) {
      return null;
    }
  }
}

class OrderSuccessEvent extends RepositoryEvent {
  const OrderSuccessEvent({required this.message});
  final String message;
}
