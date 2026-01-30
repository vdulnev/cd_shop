import 'dart:async';

import 'package:get_it/get_it.dart' hide Disposable;
import 'package:talker/talker.dart';

import 'package:cd_shop/core/models/disposable.dart';

import 'package:cd_shop/core/database/app_database.dart';
import 'package:cd_shop/core/di/dependency_factory.dart';
import 'package:cd_shop/core/di/firebase_dependency_factory.dart';
import 'package:cd_shop/core/services/analytics_observer.dart';
import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/address/domain/usecases/add_address.dart';
import 'package:cd_shop/features/address/domain/usecases/delete_address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/address/domain/usecases/update_address.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/set_default_address.dart';
import 'package:cd_shop/features/auth/domain/usecases/watch_current_user.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/cart/domain/usecases/watch_cart.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/order/domain/usecases/cancel_order.dart';
import 'package:cd_shop/features/order/domain/usecases/place_order.dart';
import 'package:cd_shop/features/order/domain/usecases/watch_user_orders.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/domain/usecases/watch_products.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// Call this function in main() before runApp().
/// Pass a custom [factory] in tests to replace Firebase services with mocks.
Future<void> initDependencies({DependencyFactory? factory}) async {
  final f = factory ?? FirebaseDependencyFactory();

  // ===== Logging =====
  sl.registerSingleton<Talker>(f.createTalker());
  final log = sl<Talker>();
  log.info('Initializing dependencies...');

  // ===== Core Services =====
  sl.registerLazySingleton<AnalyticsService>(
    () => f.createAnalyticsService(),
  );
  sl.registerLazySingleton<AnalyticsObserver>(
    () => f.createAnalyticsObserver(
      analyticsService: sl<AnalyticsService>(),
    ),
  );
  log.info('Core services registered');

  // ===== Core (Database - kept for offline caching) =====
  await _initDatabase();
  log.info('Database initialized');

  // ===== Features =====
  _initAuthFeature(f);
  log.info('Auth feature initialized');
  _initProductFeature(f);
  log.info('Product feature initialized');
  _initCartFeature(f);
  log.info('Cart feature initialized');
  _initAddressFeature(f);
  log.info('Address feature initialized');
  _initOrderFeature(f);
  log.info('Order feature initialized');

  // Eagerly initialize so the observer starts listening immediately
  sl<AnalyticsObserver>();
  log.info('Analytics observer started');

  log.info('All dependencies initialized');
}

/// Initialize database (kept for offline caching)
Future<void> _initDatabase() async {
  final database = await AppDatabase.create();
  sl.registerSingleton<AppDatabase>(database);
}

/// Initialize Auth feature dependencies
void _initAuthFeature(DependencyFactory f) {
  // Use Cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => SetDefaultAddress(sl()));
  sl.registerLazySingleton(() => WatchCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => f.createAuthRepository(),
    dispose: (i) => _dispose(i),
  );
}

/// Initialize Product feature dependencies
void _initProductFeature(DependencyFactory f) {
  // Use Cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => GetProductById(sl()));
  sl.registerLazySingleton(() => WatchProducts(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => f.createProductRepository(),
    dispose: (i) => _dispose(i),
  );
}

/// Initialize Cart feature dependencies
void _initCartFeature(DependencyFactory f) {
  // Use Cases
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantity(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));
  sl.registerLazySingleton(() => WatchCart(sl()));

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => f.createCartRepository(),
    dispose: (i) => _dispose(i),
  );
}

/// Initialize Address feature dependencies
void _initAddressFeature(DependencyFactory f) {
  // Use Cases
  sl.registerLazySingleton(() => WatchAddresses(sl()));
  sl.registerLazySingleton(() => AddAddress(sl()));
  sl.registerLazySingleton(() => UpdateAddress(sl()));
  sl.registerLazySingleton(() => DeleteAddress(sl()));

  // Repository
  sl.registerLazySingleton<AddressRepository>(
    () => f.createAddressRepository(),
    dispose: (i) => _dispose(i),
  );
}

/// Initialize Order/Checkout feature dependencies
void _initOrderFeature(DependencyFactory f) {
  // Use Cases
  sl.registerLazySingleton(() => PlaceOrder(sl()));
  sl.registerLazySingleton(() => WatchUserOrders(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => f.createOrderRepository(),
    dispose: (i) => _dispose(i),
  );
}

void _dispose(Object instance) {
  if (instance is Disposable) {
    instance.dispose();
  }
}
