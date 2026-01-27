import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';

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
