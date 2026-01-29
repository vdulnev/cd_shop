import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:dartz/dartz.dart' hide Order;
import 'package:uuid/uuid.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Firestore implementation of [OrderRepository].
///
/// Stores orders as documents in the 'orders' collection.
class FirestoreOrderRepositoryImpl implements OrderRepository {
  FirestoreOrderRepositoryImpl({
    FirebaseFirestore? firestore,
    this.analyticsService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final AnalyticsService? analyticsService;
  final _eventController = StreamController<RepositoryEvent>.broadcast();
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> _addressesRef(String userId) =>
      _firestore.collection('addresses').doc(userId).collection('items');

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;

  @override
  Future<Either<Failure, Order>> placeOrder(OrderRequest request) async {
    try {
      // Fetch the shipping address
      final addressDoc =
          await _addressesRef(request.userId).doc(request.shippingAddressId).get();

      if (!addressDoc.exists) {
        return const Left(
            NotFoundFailure(message: 'Shipping address not found'));
      }

      final addressData = addressDoc.data()!;
      final shippingAddress = Address(
        id: addressDoc.id,
        userId: request.userId,
        name: addressData['name'] as String? ?? '',
        street: addressData['street'] as String? ?? '',
        city: addressData['city'] as String? ?? '',
        state: addressData['state'] as String? ?? '',
        zipCode: addressData['zipCode'] as String? ?? '',
        country: addressData['country'] as String? ?? '',
      );

      // Calculate costs
      final subtotal =
          request.items.fold(0.0, (acc, item) => acc + item.totalPrice);
      const shippingCost = 5.99;
      final tax = subtotal * 0.08;
      final total = subtotal + shippingCost + tax;

      // Generate order ID
      final orderId = _uuid.v4();
      final orderDate = DateTime.now();
      final estimatedDeliveryDate = orderDate.add(const Duration(days: 7));

      // Create order document
      await _ordersRef.doc(orderId).set({
        'userId': request.userId,
        'items': request.items
            .map((item) => {
                  'productId': item.product.id,
                  'productTitle': item.product.title,
                  'productArtist': item.product.artist,
                  'productPrice': item.product.price,
                  'productImageUrl': item.product.imageUrl,
                  'quantity': item.quantity,
                })
            .toList(),
        'shippingAddress': {
          'id': shippingAddress.id,
          'name': shippingAddress.name,
          'street': shippingAddress.street,
          'city': shippingAddress.city,
          'state': shippingAddress.state,
          'zipCode': shippingAddress.zipCode,
          'country': shippingAddress.country,
        },
        'paymentMethod': request.paymentMethod.name,
        'subtotal': subtotal,
        'shippingCost': shippingCost,
        'tax': tax,
        'total': total,
        'status': OrderStatus.pending.name,
        'orderDate': Timestamp.fromDate(orderDate),
        'estimatedDeliveryDate': Timestamp.fromDate(estimatedDeliveryDate),
        'notes': request.notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create domain order object
      final order = Order(
        id: orderId,
        userId: request.userId,
        items: request.items,
        shippingAddress: shippingAddress,
        paymentMethod: request.paymentMethod,
        subtotal: subtotal,
        shippingCost: shippingCost,
        tax: tax,
        total: total,
        status: OrderStatus.pending,
        orderDate: orderDate,
        estimatedDeliveryDate: estimatedDeliveryDate,
        notes: request.notes,
      );

      // Track analytics
      await analyticsService?.logPurchase(
        orderId: orderId,
        total: total,
        shipping: shippingCost,
        tax: tax,
        items: request.items,
      );

      _eventController.add(
        const SuccessEvent(message: 'Order placed successfully'),
      );

      return Right(order);
    } catch (e) {
      _eventController.add(
        const ErrorEvent(message: 'Failed to place order'),
      );
      return const Left(CacheFailure(message: 'Failed to place order'));
    }
  }

  @override
  Stream<List<Order>> watchUserOrders(String userId) {
    return _ordersRef
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => _documentToOrder(doc))
          .whereType<Order>()
          .toList();
    });
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final doc = await _ordersRef.doc(orderId).get();
      if (!doc.exists) {
        return const Left(NotFoundFailure(message: 'Order not found'));
      }

      final order = _documentToOrder(doc);
      if (order == null) {
        return const Left(CacheFailure(message: 'Failed to load order'));
      }

      return Right(order);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to load order'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      final doc = await _ordersRef.doc(orderId).get();
      if (!doc.exists) {
        return const Left(NotFoundFailure(message: 'Order not found'));
      }

      await _ordersRef.doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _eventController.add(
        const SuccessEvent(message: 'Order cancelled successfully'),
      );

      return const Right(null);
    } catch (e) {
      _eventController.add(
        const ErrorEvent(message: 'Failed to cancel order'),
      );
      return const Left(CacheFailure(message: 'Failed to cancel order'));
    }
  }

  Order? _documentToOrder(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;

      // Parse items
      final itemsData = data['items'] as List<dynamic>? ?? [];
      final items = itemsData.map((itemData) {
        final itemMap = itemData as Map<String, dynamic>;
        final product = Product(
          id: itemMap['productId'] as String? ?? '',
          title: itemMap['productTitle'] as String? ?? '',
          artist: itemMap['productArtist'] as String? ?? '',
          description: '',
          price: (itemMap['productPrice'] as num?)?.toDouble() ?? 0.0,
          imageUrl: itemMap['productImageUrl'] as String?,
          genre: ProductGenre.rock,
          stockQuantity: 0,
        );
        return CartItem(
          product: product,
          quantity: itemMap['quantity'] as int? ?? 1,
        );
      }).toList();

      // Parse shipping address
      final addressData = data['shippingAddress'] as Map<String, dynamic>? ?? {};
      final shippingAddress = Address(
        id: addressData['id'] as String? ?? '',
        userId: data['userId'] as String? ?? '',
        name: addressData['name'] as String? ?? '',
        street: addressData['street'] as String? ?? '',
        city: addressData['city'] as String? ?? '',
        state: addressData['state'] as String? ?? '',
        zipCode: addressData['zipCode'] as String? ?? '',
        country: addressData['country'] as String? ?? '',
      );

      // Parse dates
      final orderDateTimestamp = data['orderDate'] as Timestamp?;
      final estimatedDeliveryTimestamp = data['estimatedDeliveryDate'] as Timestamp?;

      return Order(
        id: doc.id,
        userId: data['userId'] as String? ?? '',
        items: items,
        shippingAddress: shippingAddress,
        paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.name == data['paymentMethod'],
          orElse: () => PaymentMethod.creditCard,
        ),
        subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
        shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
        tax: (data['tax'] as num?)?.toDouble() ?? 0.0,
        total: (data['total'] as num?)?.toDouble() ?? 0.0,
        status: OrderStatus.values.firstWhere(
          (e) => e.name == data['status'],
          orElse: () => OrderStatus.pending,
        ),
        orderDate: orderDateTimestamp?.toDate() ?? DateTime.now(),
        estimatedDeliveryDate: estimatedDeliveryTimestamp?.toDate(),
        notes: data['notes'] as String?,
      );
    } catch (e) {
      return null;
    }
  }
}
