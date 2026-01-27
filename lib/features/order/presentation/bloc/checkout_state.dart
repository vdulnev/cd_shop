import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';

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
