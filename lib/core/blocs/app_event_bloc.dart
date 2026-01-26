import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// BLoC that aggregates repository event streams for centralized UI notifications
class AppEventBloc extends Cubit<RepositoryEvent?> {
  AppEventBloc({
    required AddressRepository addressRepository,
    required AuthRepository authRepository,
    required CartRepository cartRepository,
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
  })  : _addressRepository = addressRepository,
        _authRepository = authRepository,
        _cartRepository = cartRepository,
        _productRepository = productRepository,
        _orderRepository = orderRepository,
        super(null) {
    _initializeListeners();
  }

  final AddressRepository _addressRepository;
  final AuthRepository _authRepository;
  final CartRepository _cartRepository;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;

  void _initializeListeners() {
    // Listen to address repository events
    _addressRepository.eventStream().listen((event) {
      emit(event);
    });

    // Listen to auth repository events
    _authRepository.eventStream().listen((event) {
      emit(event);
    });

    // Listen to cart repository events
    _cartRepository.eventStream().listen((event) {
      emit(event);
    });

    // Listen to product repository events
    _productRepository.eventStream().listen((event) {
      emit(event);
    });

    // Listen to order repository events
    _orderRepository.eventStream().listen((event) {
      emit(event);
    });
  }
}
