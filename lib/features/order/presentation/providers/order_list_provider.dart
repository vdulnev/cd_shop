import 'dart:async';

import 'package:cd_shop/features/order/domain/usecases/cancel_order.dart';
import 'package:cd_shop/features/order/domain/usecases/watch_user_orders.dart';
import 'package:cd_shop/features/order/presentation/providers/order_list_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderListNotifier extends Notifier<OrderListState> {
  OrderListNotifier(
    this._userId,
  );

  final String _userId;

  late final WatchUserOrders _watchUserOrders;
  late final CancelOrder _cancelOrder;
  StreamSubscription? _subscription;

  @override
  OrderListState build() {
    _watchUserOrders = sl<WatchUserOrders>();
    _cancelOrder = sl<CancelOrder>();
    _subscribe(_userId);
    return const OrderListLoading();
  }

  void _subscribe(String userId) {
    _subscription?.cancel();
    _subscription = _watchUserOrders(userId).listen(
      (orders) {
        state = OrderListLoaded(orders);
      },
      onError: (error) {
        state = OrderListError(error.toString());
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  Future<void> cancelOrder(String orderId) async {
    final result = await _cancelOrder(orderId);
    result.fold(
      (failure) => state = OrderListError(failure.message),
      (_) => _resubscribeIfPossible(),
    );
  }

  void _resubscribeIfPossible() {
    _subscribe(_userId);
  }
}

final orderListProvider =
    NotifierProvider.family<OrderListNotifier, OrderListState, String>(
  (userId) => OrderListNotifier(userId),
);
