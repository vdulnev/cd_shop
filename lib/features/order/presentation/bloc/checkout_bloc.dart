import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/usecases/place_order.dart';

// Events
sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted(this.userId, this.cartItems);

  final String userId;
  final List<CartItem> cartItems;

  @override
  List<Object?> get props => [userId, cartItems];
}

class CheckoutAddressSelected extends CheckoutEvent {
  const CheckoutAddressSelected(this.address);

  final Address? address;

  @override
  List<Object?> get props => [address];
}

class CheckoutPaymentMethodSelected extends CheckoutEvent {
  const CheckoutPaymentMethodSelected(this.paymentMethod);

  final PaymentMethod paymentMethod;

  @override
  List<Object?> get props => [paymentMethod];
}

class CheckoutNotesChanged extends CheckoutEvent {
  const CheckoutNotesChanged(this.notes);

  final String notes;

  @override
  List<Object?> get props => [notes];
}

class CheckoutOrderPlaced extends CheckoutEvent {
  const CheckoutOrderPlaced();
}

// States
sealed class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

class CheckoutReady extends CheckoutState {
  const CheckoutReady({
    required this.userId,
    required this.cartItems,
    required this.addresses,
    this.selectedAddress,
    this.selectedPaymentMethod,
    this.notes,
  });

  final String userId;
  final List<CartItem> cartItems;
  final List<Address> addresses;
  final Address? selectedAddress;
  final PaymentMethod? selectedPaymentMethod;
  final String? notes;

  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get shippingCost => 5.99;
  double get tax => subtotal * 0.08;
  double get total => subtotal + shippingCost + tax;

  bool get canPlaceOrder =>
      selectedAddress != null && selectedPaymentMethod != null;

  CheckoutReady copyWith({
    String? userId,
    List<CartItem>? cartItems,
    List<Address>? addresses,
    Address? selectedAddress,
    PaymentMethod? selectedPaymentMethod,
    String? notes,
  }) {
    return CheckoutReady(
      userId: userId ?? this.userId,
      cartItems: cartItems ?? this.cartItems,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        cartItems,
        addresses,
        selectedAddress,
        selectedPaymentMethod,
        notes,
      ];
}

class CheckoutPlacingOrder extends CheckoutState {
  const CheckoutPlacingOrder();
}

class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// BLoC
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
