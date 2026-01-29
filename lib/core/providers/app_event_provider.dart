import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/injection_container.dart';

final appEventProvider = StreamProvider<RepositoryEvent>((ref) {
  final emitters = [
    sl<AddressRepository>(),
    sl<AuthRepository>(),
    sl<CartRepository>(),
    sl<ProductRepository>(),
    sl<OrderRepository>(),
  ].whereType<EventEmitter>().toList();

  return MergeStream<RepositoryEvent>(
    emitters.map((e) => e.eventStream()).toList(),
  );
});
