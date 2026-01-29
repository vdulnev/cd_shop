import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/usecases/place_order.dart';
import 'package:cd_shop/features/order/presentation/providers/checkout_state.dart';
import 'package:cd_shop/injection_container.dart';

class CheckoutParams extends Equatable {
  const CheckoutParams({
    required this.userId,
    required this.cartItems,
  });

  final String userId;
  final List<CartItem> cartItems;

  @override
  List<Object?> get props => [userId, cartItems];
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier({
    required WatchAddresses watchAddresses,
    required PlaceOrder placeOrder,
    required ClearCart clearCart,
    required AnalyticsService analyticsService,
    required CheckoutParams params,
  })  : _watchAddresses = watchAddresses,
        _placeOrder = placeOrder,
        _clearCart = clearCart,
        _analyticsService = analyticsService,
        _params = params,
        super(const CheckoutInitial()) {
    _subscribe();
  }

  final WatchAddresses _watchAddresses;
  final PlaceOrder _placeOrder;
  final ClearCart _clearCart;
  final AnalyticsService _analyticsService;
  final CheckoutParams _params;

  StreamSubscription<List<Address>>? _addressSubscription;

  void _subscribe() {
    state = const CheckoutLoading();
    _addressSubscription?.cancel();
    _addressSubscription = _watchAddresses(_params.userId).listen(
      (addresses) {
        final selected = _resolveSelectedAddress(addresses);
        if (state is CheckoutReady) {
          final current = state as CheckoutReady;
          state = current.copyWith(
            addresses: addresses,
            selectedAddress: selected,
          );
        } else {
          state = CheckoutReady(
            userId: _params.userId,
            cartItems: _params.cartItems,
            addresses: addresses,
            selectedAddress: selected,
          );
        }
      },
      onError: (error) => state = CheckoutError(error.toString()),
    );
  }

  Address? _resolveSelectedAddress(List<Address> addresses) {
    if (addresses.isEmpty) {
      return null;
    }
    if (state is CheckoutReady) {
      final current = state as CheckoutReady;
      if (current.selectedAddress != null &&
          addresses.any((a) => a.id == current.selectedAddress!.id)) {
        return current.selectedAddress;
      }
    }
    return addresses.firstOrNull;
  }

  void selectAddress(Address? address) {
    if (state is CheckoutReady) {
      final current = state as CheckoutReady;
      state = current.copyWith(selectedAddress: address);
    }
  }

  void selectPaymentMethod(PaymentMethod paymentMethod) {
    if (state is CheckoutReady) {
      final current = state as CheckoutReady;
      state = current.copyWith(selectedPaymentMethod: paymentMethod);
    }
  }

  void updateNotes(String notes) {
    if (state is CheckoutReady) {
      final current = state as CheckoutReady;
      state = current.copyWith(notes: notes);
    }
  }

  Future<void> placeOrder() async {
    if (state is! CheckoutReady) return;

    final current = state as CheckoutReady;
    if (!current.canPlaceOrder) {
      state = const CheckoutError('Please select address and payment method');
      return;
    }

    state = const CheckoutPlacingOrder();

    final total = current.cartItems.fold<double>(
      0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
    _analyticsService.logBeginCheckout(current.cartItems, total);

    final request = OrderRequest(
      userId: current.userId,
      items: current.cartItems,
      shippingAddressId: current.selectedAddress!.id,
      paymentMethod: current.selectedPaymentMethod!,
      notes: current.notes,
    );

    final result = await _placeOrder(request);

    if (result.isLeft()) {
      final failure = result.fold(
        (f) => f,
        (_) => throw StateError('unreachable'),
      );
      state = CheckoutError(failure.message);
      return;
    }

    final order = result.fold(
      (_) => throw StateError('unreachable'),
      (o) => o,
    );
    await _clearCart(const NoParams());
    state = CheckoutSuccess(order);
  }

  @override
  void dispose() {
    _addressSubscription?.cancel();
    super.dispose();
  }
}

final checkoutProvider = StateNotifierProvider.autoDispose.family<
    CheckoutNotifier,
    CheckoutState,
    CheckoutParams>((ref, params) {
  return CheckoutNotifier(
    watchAddresses: sl<WatchAddresses>(),
    placeOrder: sl<PlaceOrder>(),
    clearCart: sl<ClearCart>(),
    analyticsService: sl<AnalyticsService>(),
    params: params,
  );
});
