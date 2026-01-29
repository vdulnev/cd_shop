import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import 'package:cd_shop/core/database/daos/cart_dao.dart';
import 'package:cd_shop/core/database/entities/cart_item_entity.dart';
import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/product/data/datasources/product_mock_datasource.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Floor database implementation of CartRepository
///
/// Persists cart items to SQLite using Floor.
/// Product details are fetched from the product datasource.
class CartRepositoryImpl
  with EventEmitterMixin
  implements CartRepository {
  CartRepositoryImpl({
    required CartDao cartDao,
    required AuthRepository authRepository,
  })  : _cartDao = cartDao,
        _authRepository = authRepository {
    _initCartStream();
  }

  final CartDao _cartDao;
  final AuthRepository _authRepository;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<CartItemEntity>>? _cartItemsSubscription;
  String? _activeUserId;

  // ignore: close_sinks - singleton repository, lives for app lifetime
  final _cartSubject = BehaviorSubject<Cart>();

  void _initCartStream() {
    _authSubscription ??= _authRepository.watchCurrentUser().listen(
      (user) => unawaited(_syncCartStreamForUser(user?.id)),
      onError: (_) => unawaited(_syncCartStreamForUser(null)),
    );
    unawaited(_syncCartStreamForUser(_activeUserId));
  }

  Future<void> _syncCartStreamForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      _activeUserId = null;
      await _cartItemsSubscription?.cancel();
      _cartItemsSubscription = null;
      _cartSubject.addError(
        const AuthFailure(message: 'Please sign in to use the cart'),
      );
      return;
    }

    if (_activeUserId == userId && _cartItemsSubscription != null) {
      return;
    }

    _activeUserId = userId;
    await _cartItemsSubscription?.cancel();
    _cartItemsSubscription = _cartDao.watchCartItems(userId).listen(
      (entities) async {
        final cart = await _entitiesToCart(entities, userId: userId);
        _cartSubject.add(cart);
      },
    );

    final initialCart = await _getCurrentCart(userId);
    _cartSubject.add(initialCart);
  }

  Future<String?> _getCurrentUserId() async {
    if (_activeUserId != null && _activeUserId!.isNotEmpty) {
      return _activeUserId;
    }
    final userResult = await _authRepository.getCurrentUser();
    return userResult.fold((_) => null, (user) => user?.id);
  }

  Future<Cart> _entitiesToCart(
    List<CartItemEntity> entities, {
    required String userId,
  }) async {
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
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        emitEvent(const ErrorEvent(message: 'Please sign in to use the cart'));
        return const Left(AuthFailure(message: 'Please sign in to use the cart'));
      }

      final existing = await _cartDao.getCartItem(userId, product.id);
      final newQuantity = (existing?.quantity ?? 0) + quantity;

      await _cartDao.insertCartItem(
        CartItemEntity(
          userId: userId,
          productId: product.id,
          quantity: newQuantity,
        ),
      );

      emitEvent(SuccessEvent(message: '${product.title} added to cart!'));

      return Right(await _getCurrentCart(userId));
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to add item to cart'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(String productId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        emitEvent(const ErrorEvent(message: 'Please sign in to use the cart'));
        return const Left(AuthFailure(message: 'Please sign in to use the cart'));
      }

      await _cartDao.deleteCartItem(userId, productId);

      emitEvent(const SuccessEvent(message: 'Item removed from cart'));

      return Right(await _getCurrentCart(userId));
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
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        emitEvent(const ErrorEvent(message: 'Please sign in to use the cart'));
        return const Left(AuthFailure(message: 'Please sign in to use the cart'));
      }

      final existing = await _cartDao.getCartItem(userId, productId);

      if (existing == null) {
        return const Left(NotFoundFailure(message: 'Item not found in cart'));
      }

      if (quantity <= 0) {
        await _cartDao.deleteCartItem(userId, productId);
      } else {
        await _cartDao.updateCartItem(
          CartItemEntity(
            userId: userId,
            productId: productId,
            quantity: quantity,
          ),
        );
      }

      return Right(await _getCurrentCart(userId));
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to update cart item'));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        emitEvent(const ErrorEvent(message: 'Please sign in to use the cart'));
        return const Left(AuthFailure(message: 'Please sign in to use the cart'));
      }

      await _cartDao.clearCart(userId);
      return Right(await _getCurrentCart(userId));
    } catch (_) {
      return const Left(CacheFailure(message: 'Failed to clear cart'));
    }
  }

  @override
  Stream<Cart> watchCart() {
    _initCartStream();
    return _cartSubject.stream;
  }

  Future<Cart> _getCurrentCart(String userId) async {
    final entities = await _cartDao.getAllCartItems(userId);
    return _entitiesToCart(entities, userId: userId);
  }

  void dispose() {
    _authSubscription?.cancel();
    _cartItemsSubscription?.cancel();
    disposeEventEmitter();
    _cartSubject.close();
  }
}