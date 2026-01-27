import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/usecases/cancel_order.dart';
import 'package:cd_shop/features/order/domain/usecases/watch_user_orders.dart';

import 'order_list_event.dart';
import 'order_list_state.dart';

export 'order_list_event.dart';
export 'order_list_state.dart';

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
