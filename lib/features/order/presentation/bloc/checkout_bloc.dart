import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/usecases/place_order.dart';

import 'checkout_event.dart';
import 'checkout_state.dart';

export 'checkout_event.dart';
export 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc({
    required this.watchAddresses,
    required this.placeOrder,
    required this.clearCart,
  }) : super(const CheckoutInitial()) {
    on<CheckoutStarted>(_onCheckoutStarted);
    on<CheckoutAddressSelected>(_onAddressSelected);
    on<CheckoutPaymentMethodSelected>(_onPaymentMethodSelected);
    on<CheckoutNotesChanged>(_onNotesChanged);
    on<CheckoutOrderPlaced>(_onOrderPlaced);
  }

  final WatchAddresses watchAddresses;
  final PlaceOrder placeOrder;
  final ClearCart clearCart;

  StreamSubscription<List<Address>>? _addressSubscription;
  String? _userId;
  List<CartItem>? _cartItems;

  Future<void> _onCheckoutStarted(
    CheckoutStarted event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(const CheckoutLoading());

    _userId = event.userId;
    _cartItems = event.cartItems;

    await _addressSubscription?.cancel();
    _addressSubscription = watchAddresses(event.userId).listen(
      (addresses) {
        if (state is CheckoutReady) {
          final currentState = state as CheckoutReady;
          add(CheckoutAddressSelected(
            currentState.selectedAddress ?? addresses.firstOrNull,
          ));
        } else {
          add(CheckoutAddressSelected(addresses.firstOrNull));
        }
      },
    );

    // Wait for first address update
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _onAddressSelected(
    CheckoutAddressSelected event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is CheckoutReady) {
      final currentState = state as CheckoutReady;
      emit(currentState.copyWith(selectedAddress: event.address));
    } else if (state is CheckoutLoading) {
      if (_userId != null && _cartItems != null) {
        emit(CheckoutReady(
          userId: _userId!,
          cartItems: _cartItems!,
          addresses: event.address != null ? [event.address!] : [],
          selectedAddress: event.address,
        ));
      }
    }
  }

  void _onPaymentMethodSelected(
    CheckoutPaymentMethodSelected event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is CheckoutReady) {
      final currentState = state as CheckoutReady;
      emit(currentState.copyWith(selectedPaymentMethod: event.paymentMethod));
    }
  }

  void _onNotesChanged(
    CheckoutNotesChanged event,
    Emitter<CheckoutState> emit,
  ) {
    if (state is CheckoutReady) {
      final currentState = state as CheckoutReady;
      emit(currentState.copyWith(notes: event.notes));
    }
  }

  Future<void> _onOrderPlaced(
    CheckoutOrderPlaced event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutReady) return;

    final currentState = state as CheckoutReady;
    if (!currentState.canPlaceOrder) {
      emit(const CheckoutError('Please select address and payment method'));
      return;
    }

    emit(const CheckoutPlacingOrder());

    final request = OrderRequest(
      userId: currentState.userId,
      items: currentState.cartItems,
      shippingAddressId: currentState.selectedAddress!.id,
      paymentMethod: currentState.selectedPaymentMethod!,
      notes: currentState.notes,
    );

    final result = await placeOrder(request);

    if (result.isLeft()) {
      final failure = result.fold((f) => f, (_) => throw StateError('unreachable'));
      emit(CheckoutError(failure.message));
    } else {
      final order = result.fold((_) => throw StateError('unreachable'), (o) => o);
      // Clear cart after successful order
      await clearCart(const NoParams());
      emit(CheckoutSuccess(order));
    }
  }

  @override
  Future<void> close() {
    _addressSubscription?.cancel();
    return super.close();
  }
}
