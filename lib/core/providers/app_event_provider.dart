import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/injection_container.dart';

final appEventProvider = StreamProvider<RepositoryEvent>((ref) {
  final addressRepository = sl<AddressRepository>();
  final authRepository = sl<AuthRepository>();
  final cartRepository = sl<CartRepository>();
  final productRepository = sl<ProductRepository>();
  final orderRepository = sl<OrderRepository>();

  return MergeStream<RepositoryEvent>([
    addressRepository.eventStream(),
    authRepository.eventStream(),
    cartRepository.eventStream(),
    productRepository.eventStream(),
    orderRepository.eventStream(),
  ]);
});
