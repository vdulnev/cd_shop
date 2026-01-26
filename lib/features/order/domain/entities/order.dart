import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';

/// Order status enumeration
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.processing => 'Processing',
        OrderStatus.shipped => 'Shipped',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };
}

/// Payment method enumeration
enum PaymentMethod {
  creditCard,
  debitCard,
  paypal,
  cashOnDelivery;

  String get label => switch (this) {
        PaymentMethod.creditCard => 'Credit Card',
        PaymentMethod.debitCard => 'Debit Card',
        PaymentMethod.paypal => 'PayPal',
        PaymentMethod.cashOnDelivery => 'Cash on Delivery',
      };
}

/// Order entity representing a placed order
class Order extends Equatable {
  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.status,
    required this.orderDate,
    this.estimatedDeliveryDate,
    this.notes,
  });

  final String id;
  final String userId;
  final List<CartItem> items;
  final Address shippingAddress;
  final PaymentMethod paymentMethod;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryDate;
  final String? notes;

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        shippingAddress,
        paymentMethod,
        subtotal,
        shippingCost,
        tax,
        total,
        status,
        orderDate,
        estimatedDeliveryDate,
        notes,
      ];
}

/// Request parameters for placing an order
class OrderRequest extends Equatable {
  const OrderRequest({
    required this.userId,
    required this.items,
    required this.shippingAddressId,
    required this.paymentMethod,
    this.notes,
  });

  final String userId;
  final List<CartItem> items;
  final String shippingAddressId;
  final PaymentMethod paymentMethod;
  final String? notes;

  @override
  List<Object?> get props => [
        userId,
        items,
        shippingAddressId,
        paymentMethod,
        notes,
      ];
}
