import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// BLoC that aggregates repository event streams for centralized UI notifications
class AppEventBloc extends Cubit<RepositoryEvent?> {
  AppEventBloc({
    required AuthRepository authRepository,
    required CartRepository cartRepository,
    required ProductRepository productRepository,
  })  : _authRepository = authRepository,
        _cartRepository = cartRepository,
        _productRepository = productRepository,
        super(null) {
    _initializeListeners();
  }

  final AuthRepository _authRepository;
  final CartRepository _cartRepository;
  final ProductRepository _productRepository;

  void _initializeListeners() {
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
  }
}
