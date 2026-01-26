import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import 'package:cd_shop/core/database/daos/cart_dao.dart';
import 'package:cd_shop/core/database/entities/cart_item_entity.dart';
import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/product/data/datasources/product_mock_datasource.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Floor database implementation of CartRepository
///
/// Persists cart items to SQLite using Floor.
/// Product details are fetched from the product datasource.
class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({
    required CartDao cartDao,
    required AuthRepository authRepository,
  })  : _cartDao = cartDao,
        _authRepository = authRepository {
    _initCartStream();
  }

  final CartDao _cartDao;
  final AuthRepository _authRepository;

  // ignore: close_sinks - singleton repository, lives for app lifetime
  final _eventController = StreamController<RepositoryEvent>.broadcast();

  // ignore: close_sinks - singleton repository, lives for app lifetime
  final _cartSubject = BehaviorSubject<Cart>.seeded(const Cart());

  void _initCartStream() {
    _cartDao.watchAllCartItems().listen((entities) async {
      final cart = await _entitiesToCart(entities);
      _cartSubject.add(cart);
    });
  }

  Future<Cart> _entitiesToCart(List<CartItemEntity> entities) async {
    final userResult = await _authRepository.getCurrentUser();
    final userId = userResult.fold((_) => '', (user) => user?.id ?? '');

    final items = <CartItem>[];
    for (final entity in entities) {
      final product = ProductMockDataSource.getById(entity.productId);
      if (product != null) {
        items.add(CartItem(product: product, quantity: entity.quantity));
      }
    }
    return Cart(userId: userId, items: items);
  }

  @override
  Future<Either<Failure, Cart>> addToCart(
    Product product, {
    int quantity = 1,
  }) async {
    try {
      final existing = await _cartDao.getCartItem(product.id);
      final newQuantity = (existing?.quantity ?? 0) + quantity;

      await _cartDao.insertCartItem(
        CartItemEntity(productId: product.id, quantity: newQuantity),
      );

      _eventController.add(
        CartSuccessEvent(message: '${product.title} added to cart!'),
      );

      return Right(await _getCurrentCart());
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to add item to cart'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(String productId) async {
    try {
      await _cartDao.deleteCartItem(productId);

      _eventController.add(
        const CartSuccessEvent(message: 'Item removed from cart'),
      );

      return Right(await _getCurrentCart());
    } catch (_) {
      return const Left(
        CacheFailure(message: 'Failed to remove item from cart'),
      );
    }
  }

  @override
  Future<Either<Failure, Cart>> updateQuantity(
    String productId,
    int quantity,
  ) async {
    try {
      final existing = await _cartDao.getCartItem(productId);

      if (existing == null) {
        return const Left(NotFoundFailure(message: 'Item not found in cart'));
      }

      if (quantity <= 0) {
        await _cartDao.deleteCartItem(productId);
      } else {
        await _cartDao.updateCartItem(
          CartItemEntity(productId: productId, quantity: quantity),
        );
      }

      return Right(await _getCurrentCart());
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to update cart item'));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart() async {
    try {
      await _cartDao.clearCart();
      return Right(await _getCurrentCart());
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to clear cart'));
    }
  }

  @override
  Stream<Cart> watchCart() => _cartSubject.stream;

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;

  Future<Cart> _getCurrentCart() async {
    final entities = await _cartDao.getAllCartItems();
    return _entitiesToCart(entities);
  }
}
