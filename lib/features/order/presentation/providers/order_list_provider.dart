import 'dart:async';

import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/usecases/cancel_order.dart';
import 'package:cd_shop/features/order/domain/usecases/watch_user_orders.dart';
import 'package:cd_shop/features/order/presentation/providers/order_list_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/legacy.dart';

class OrderListNotifier extends StateNotifier<OrderListState> {
  OrderListNotifier({
    required WatchUserOrders watchUserOrders,
    required CancelOrder cancelOrder,
    required String userId,
  })  : _watchUserOrders = watchUserOrders,
        _cancelOrder = cancelOrder,
        _userId = userId,
        super(const OrderListInitial()) {
    _subscribe();
  }

  final WatchUserOrders _watchUserOrders;
  final CancelOrder _cancelOrder;
  final String _userId;

  StreamSubscription<List<Order>>? _subscription;

  void _subscribe() {
    state = const OrderListLoading();
    _subscription?.cancel();
    _subscription = _watchUserOrders(_userId).listen(
      (orders) => state = OrderListLoaded(orders),
      onError: (error) => state = OrderListError(error.toString()),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    await _cancelOrder(orderId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final orderListProvider = StateNotifierProvider.autoDispose
    .family<OrderListNotifier, OrderListState, String>((ref, userId) {
  return OrderListNotifier(
    watchUserOrders: sl<WatchUserOrders>(),
    cancelOrder: sl<CancelOrder>(),
    userId: userId,
  );
});
