import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/usecases/cancel_order.dart';
import 'package:cd_shop/features/order/domain/usecases/watch_user_orders.dart';

// Events
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

// States
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

// BLoC
class OrderListBloc extends Bloc<OrderListEvent, OrderListState> {
  OrderListBloc({
    required WatchUserOrders watchUserOrders,
    required CancelOrder cancelOrder,
  })  : _watchUserOrders = watchUserOrders,
        _cancelOrder = cancelOrder,
        super(const OrderListInitial()) {
    on<OrderListStarted>(_onStarted);
    on<OrderListUpdated>(_onUpdated);
    on<OrderCancellationRequested>(_onCancellationRequested);
  }

  final WatchUserOrders _watchUserOrders;
  final CancelOrder _cancelOrder;

  StreamSubscription<List<Order>>? _ordersSubscription;

  Future<void> _onStarted(
    OrderListStarted event,
    Emitter<OrderListState> emit,
  ) async {
    emit(const OrderListLoading());

    await _ordersSubscription?.cancel();
    _ordersSubscription = _watchUserOrders(event.userId).listen(
      (orders) => add(OrderListUpdated(orders)),
    );
  }

  void _onUpdated(
    OrderListUpdated event,
    Emitter<OrderListState> emit,
  ) {
    emit(OrderListLoaded(event.orders));
  }

  Future<void> _onCancellationRequested(
    OrderCancellationRequested event,
    Emitter<OrderListState> emit,
  ) async {
    final result = await _cancelOrder(event.orderId);

    result.fold(
      (failure) {
        // Show error but keep current state
      },
      (_) {
        // Order will be updated via stream
      },
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
