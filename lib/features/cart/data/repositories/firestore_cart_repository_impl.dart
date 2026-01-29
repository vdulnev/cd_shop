import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/analytics_event.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Firestore implementation of [CartRepository].
///
/// Stores cart items in Firestore subcollections under each user.
/// Structure: carts/{userId}/items/{productId}
class FirestoreCartRepositoryImpl implements CartRepository {
  FirestoreCartRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
    this.analyticsEventBus,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository {
    _initCartStream();
  }

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final AnalyticsEventBus? analyticsEventBus;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSubscription;
  String? _activeUserId;

  final _eventController = StreamController<RepositoryEvent>.broadcast();
  final _cartSubject = BehaviorSubject<Cart>();

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> _cartItemsRef(String userId) =>
      _firestore.collection('carts').doc(userId).collection('items');

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
      await _cartSubscription?.cancel();
      _cartSubscription = null;
      _cartSubject.addError(
        const AuthFailure(message: 'Please sign in to use the cart'),
      );
      return;
    }

    if (_activeUserId == userId && _cartSubscription != null) {
      return;
    }

    _activeUserId = userId;
    await _cartSubscription?.cancel();

    _cartSubscription = _cartItemsRef(userId).snapshots().listen(
      (snapshot) async {
        final cart = await _snapshotToCart(snapshot, userId: userId);
        _cartSubject.add(cart);
      },
      onError: (error) {
        _cartSubject.addError(
          const CacheFailure(message: 'Failed to load cart'),
        );
      },
    );

    // Emit initial cart
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

  Future<Cart> _snapshotToCart(
    QuerySnapshot<Map<String, dynamic>> snapshot, {
    required String userId,
  }) async {
    final items = <CartItem>[];

    for (final doc in snapshot.docs) {
      final productId = doc.id;
      final quantity = doc.data()['quantity'] as int? ?? 1;

      final product = await _getProduct(productId);
      if (product != null) {
        items.add(CartItem(product: product, quantity: quantity));
      }
    }

    return Cart(userId: userId, items: items);
  }

  Future<Product?> _getProduct(String productId) async {
    try {
      final doc = await _productsRef.doc(productId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Product(
        id: doc.id,
        title: data['title'] as String? ?? '',
        artist: data['artist'] as String? ?? '',
        description: data['description'] as String? ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: data['imageUrl'] as String?,
        genre: _parseGenre(data['genre'] as String?),
        releaseYear: data['releaseYear'] as int?,
        stockQuantity: data['stockQuantity'] as int? ?? 0,
        isAvailable: data['isAvailable'] as bool? ?? true,
      );
    } catch (_) {
      return null;
    }
  }

  ProductGenre _parseGenre(String? genreString) {
    if (genreString == null) return ProductGenre.rock;
    try {
      return ProductGenre.values.firstWhere(
        (g) => g.name == genreString,
        orElse: () => ProductGenre.rock,
      );
    } catch (_) {
      return ProductGenre.rock;
    }
  }

  @override
  Future<Either<Failure, Cart>> addToCart(
    Product product, {
    int quantity = 1,
  }) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        _eventController.add(
          const ErrorEvent(message: 'Please sign in to use the cart'),
        );
        return const Left(
            AuthFailure(message: 'Please sign in to use the cart'));
      }

      final itemRef = _cartItemsRef(userId).doc(product.id);
      final existingDoc = await itemRef.get();
      final existingQuantity = existingDoc.data()?['quantity'] as int? ?? 0;
      final newQuantity = existingQuantity + quantity;

      await itemRef.set({
        'quantity': newQuantity,
        'addedAt': FieldValue.serverTimestamp(),
      });

      // Track analytics
      analyticsEventBus?.emit(AddToCartAnalyticsEvent(product: product, quantity: quantity));

      _eventController.add(
        SuccessEvent(message: '${product.title} added to cart!'),
      );

      return Right(await _getCurrentCart(userId));
    } catch (_) {
      _eventController.add(
        const ErrorEvent(message: 'Failed to add item to cart'),
      );
      return const Left(CacheFailure(message: 'Failed to add item to cart'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeFromCart(String productId) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        _eventController.add(
          const ErrorEvent(message: 'Please sign in to use the cart'),
        );
        return const Left(
            AuthFailure(message: 'Please sign in to use the cart'));
      }

      // Get product for analytics before removing
      final product = await _getProduct(productId);
      final existingDoc = await _cartItemsRef(userId).doc(productId).get();
      final quantity = existingDoc.data()?['quantity'] as int? ?? 1;

      await _cartItemsRef(userId).doc(productId).delete();

      // Track analytics
      if (product != null) {
        analyticsEventBus?.emit(RemoveFromCartAnalyticsEvent(product: product, quantity: quantity));
      }

      _eventController.add(
        const SuccessEvent(message: 'Item removed from cart'),
      );

      return Right(await _getCurrentCart(userId));
    } catch (_) {
      _eventController.add(
        const ErrorEvent(message: 'Failed to remove item from cart'),
      );
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
        _eventController.add(
          const ErrorEvent(message: 'Please sign in to use the cart'),
        );
        return const Left(
            AuthFailure(message: 'Please sign in to use the cart'));
      }

      final itemRef = _cartItemsRef(userId).doc(productId);
      final existingDoc = await itemRef.get();

      if (!existingDoc.exists) {
        return const Left(NotFoundFailure(message: 'Item not found in cart'));
      }

      if (quantity <= 0) {
        await itemRef.delete();
      } else {
        await itemRef.update({
          'quantity': quantity,
        });
      }

      return Right(await _getCurrentCart(userId));
    } catch (_) {
      _eventController.add(
        const ErrorEvent(message: 'Failed to update cart item'),
      );
      return const Left(CacheFailure(message: 'Failed to update cart item'));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        _eventController.add(
          const ErrorEvent(message: 'Please sign in to use the cart'),
        );
        return const Left(
            AuthFailure(message: 'Please sign in to use the cart'));
      }

      // Delete all items in the cart subcollection
      final snapshot = await _cartItemsRef(userId).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return Right(Cart.empty(userId: userId));
    } catch (_) {
      _eventController.add(
        const ErrorEvent(message: 'Failed to clear cart'),
      );
      return const Left(CacheFailure(message: 'Failed to clear cart'));
    }
  }

  @override
  Stream<Cart> watchCart() {
    _initCartStream();
    return _cartSubject.stream;
  }

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;

  Future<Cart> _getCurrentCart(String userId) async {
    try {
      final snapshot = await _cartItemsRef(userId).get();
      return _snapshotToCart(snapshot, userId: userId);
    } catch (_) {
      return Cart.empty(userId: userId);
    }
  }

  void dispose() {
    _authSubscription?.cancel();
    _cartSubscription?.cancel();
    _eventController.close();
    _cartSubject.close();
  }
}
