import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/order/domain/entities/order.dart';

sealed class OrderListState extends Equatable {
  const OrderListState();

  @override
  List<Object?> get props => [];
}

class OrderListInitial extends OrderListState {
  const OrderListInitial();
}

class OrderListLoading extends OrderListState {
  const OrderListLoading();
}

class OrderListLoaded extends OrderListState {
  const OrderListLoaded(this.orders);

  final List<Order> orders;

  @override
  List<Object?> get props => [orders];
}

class OrderListError extends OrderListState {
  const OrderListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
