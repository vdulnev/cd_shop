import 'dart:async';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/usecases/place_order.dart';
import 'package:cd_shop/features/order/presentation/providers/checkout_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutNotifier extends Notifier<CheckoutState> {
  CheckoutNotifier(this._params);

  final ({String userId, List<CartItem> cartItems}) _params;

  late final WatchAddresses _watchAddresses;
  late final PlaceOrder _placeOrder;
  late final ClearCart _clearCart;
  StreamSubscription<List<Address>>? _subscription;

  @override
  CheckoutState build() {
    _watchAddresses = sl<WatchAddresses>();
    _placeOrder = sl<PlaceOrder>();
    _clearCart = sl<ClearCart>();
    _subscribe(_params);
    return const CheckoutInitial();
  }

  void _subscribe(({String userId, List<CartItem> cartItems}) params) {
    _subscription?.cancel();
    _subscription = _watchAddresses(params.userId).listen(
      (addresses) {
        final current = state;
        final selectedAddress = _resolveSelectedAddress(addresses, current);
        final selectedPaymentMethod = current is CheckoutReady
            ? current.selectedPaymentMethod
            : null;
        final notes = current is CheckoutReady ? current.notes : null;

        state = CheckoutReady(
          userId: params.userId,
          cartItems: params.cartItems,
          addresses: addresses,
          selectedAddress: selectedAddress,
          selectedPaymentMethod: selectedPaymentMethod,
          notes: notes,
        );
      },
      onError: (error) {
        state = CheckoutError(error.toString());
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });
  }

  Address? _resolveSelectedAddress(
    List<Address> addresses,
    CheckoutState current,
  ) {
    if (addresses.isEmpty) return null;

    if (current is CheckoutReady) {
      final selectedId = current.selectedAddress?.id;
      if (selectedId != null) {
        for (final address in addresses) {
          if (address.id == selectedId) return address;
        }
      }
    }

    return addresses.first;
  }

  void selectAddress(Address? address) {
    final current = state;
    if (current is CheckoutReady) {
      state = current.copyWith(selectedAddress: address);
    }
  }

  void selectPaymentMethod(PaymentMethod method) {
    final current = state;
    if (current is CheckoutReady) {
      state = current.copyWith(selectedPaymentMethod: method);
    }
  }

  void updateNotes(String notes) {
    final current = state;
    if (current is CheckoutReady) {
      state = current.copyWith(notes: notes);
    }
  }

  Future<void> placeOrder() async {
    final current = state;
    if (current is! CheckoutReady) return;
    final address = current.selectedAddress;
    final paymentMethod = current.selectedPaymentMethod;
    if (address == null || paymentMethod == null) return;

    state = const CheckoutPlacingOrder();

    final result = await _placeOrder(
      OrderRequest(
        userId: current.userId,
        items: current.cartItems,
        shippingAddressId: address.id,
        paymentMethod: paymentMethod,
        notes: current.notes,
      ),
    );

    result.fold(
      (failure) => state = CheckoutError(failure.message),
      (order) async {
        await _clearCart(const NoParams());
        state = CheckoutSuccess(order);
      },
    );
  }

  void reset() {
    state = const CheckoutInitial();
  }
}

final checkoutProvider =
    NotifierProvider.family<CheckoutNotifier, CheckoutState,
        ({String userId, List<CartItem> cartItems})>(
  (params) => CheckoutNotifier(params),
);
