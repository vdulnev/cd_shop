import 'package:floor/floor.dart';

import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';

/// Database entity for order
@Entity(tableName: 'orders')
class OrderEntity {
  OrderEntity({
    required this.id,
    required this.userId,
    required this.shippingAddressId,
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

  factory OrderEntity.fromDomain(Order order) {
    return OrderEntity(
      id: order.id,
      userId: order.userId,
      shippingAddressId: order.shippingAddress.id,
      paymentMethod: order.paymentMethod.name,
      subtotal: order.subtotal,
      shippingCost: order.shippingCost,
      tax: order.tax,
      total: order.total,
      status: order.status.name,
      orderDate: order.orderDate.millisecondsSinceEpoch,
      estimatedDeliveryDate: order.estimatedDeliveryDate?.millisecondsSinceEpoch,
      notes: order.notes,
    );
  }

  @PrimaryKey()
  final String id;
  final String userId;
  final String shippingAddressId;
  final String paymentMethod;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final String status;
  final int orderDate;
  final int? estimatedDeliveryDate;
  final String? notes;
}

/// Database entity for order items
@Entity(
  tableName: 'order_items',
  foreignKeys: [
    ForeignKey(
      childColumns: ['orderId'],
      parentColumns: ['id'],
      entity: OrderEntity,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class OrderItemEntity {
  OrderItemEntity({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productTitle,
    required this.productArtist,
    required this.productPrice,
    this.productImageUrl,
    required this.quantity,
  });

  factory OrderItemEntity.fromCartItem(String orderId, CartItem item) {
    return OrderItemEntity(
      orderId: orderId,
      productId: item.product.id,
      productTitle: item.product.title,
      productArtist: item.product.artist,
      productPrice: item.product.price,
      productImageUrl: item.product.imageUrl,
      quantity: item.quantity,
    );
  }

  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String orderId;
  final String productId;
  final String productTitle;
  final String productArtist;
  final double productPrice;
  final String? productImageUrl;
  final int quantity;
}
