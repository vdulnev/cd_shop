import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/order/domain/entities/order.dart';

sealed class OrderListEvent extends Equatable {
  const OrderListEvent();

  @override
  List<Object?> get props => [];
}

class OrderListStarted extends OrderListEvent {
  const OrderListStarted(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class OrderListUpdated extends OrderListEvent {
  const OrderListUpdated(this.orders);

  final List<Order> orders;

  @override
  List<Object?> get props => [orders];
}

class OrderCancellationRequested extends OrderListEvent {
  const OrderCancellationRequested(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
