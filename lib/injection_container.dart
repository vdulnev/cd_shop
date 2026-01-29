import 'package:get_it/get_it.dart';

import 'package:cd_shop/core/database/app_database.dart';
import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/features/address/data/repositories/firestore_address_repository_impl.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/address/domain/usecases/add_address.dart';
import 'package:cd_shop/features/address/domain/usecases/delete_address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/address/domain/usecases/update_address.dart';
import 'package:cd_shop/features/auth/data/repositories/firebase_auth_repository_impl.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/set_default_address.dart';
import 'package:cd_shop/features/auth/domain/usecases/watch_current_user.dart';
import 'package:cd_shop/features/cart/data/repositories/firestore_cart_repository_impl.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/cart/domain/usecases/watch_cart.dart';
import 'package:cd_shop/features/order/data/repositories/firestore_order_repository_impl.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/order/domain/usecases/cancel_order.dart';
import 'package:cd_shop/features/order/domain/usecases/place_order.dart';
import 'package:cd_shop/features/order/domain/usecases/watch_user_orders.dart';
import 'package:cd_shop/features/product/data/repositories/firestore_product_repository_impl.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/domain/usecases/watch_products.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// Call this function in main() before runApp()
Future<void> initDependencies() async {
  // ===== Core Services =====
  await _initCoreServices();

  // ===== Core (Database - kept for offline caching) =====
  await _initDatabase();

  // ===== Features =====
  await _initAuthFeature();
  await _initProductFeature();
  await _initCartFeature();
  await _initAddressFeature();
  await _initOrderFeature();
}

/// Initialize core services (Analytics)
Future<void> _initCoreServices() async {
  // Analytics Service
  sl.registerLazySingleton(() => AnalyticsService());
}

/// Initialize database (kept for offline caching)
Future<void> _initDatabase() async {
  final database = await AppDatabase.create();
  sl.registerSingleton<AppDatabase>(database);
}

/// Initialize Auth feature dependencies
Future<void> _initAuthFeature() async {
  // Use Cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => SetDefaultAddress(sl()));
  sl.registerLazySingleton(() => WatchCurrentUser(sl()));

  // Repository - Firebase implementation
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepositoryImpl(
      analyticsService: sl<AnalyticsService>(),
    ),
  );
}

/// Initialize Product feature dependencies
Future<void> _initProductFeature() async {
  // Use Cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => GetProductById(sl()));
  sl.registerLazySingleton(() => WatchProducts(sl()));

  // Repository - Firestore with Floor cache
  sl.registerLazySingleton<ProductRepository>(
    () => FirestoreProductRepositoryImpl(
      productDao: sl<AppDatabase>().productDao,
    ),
  );
}

/// Initialize Cart feature dependencies
Future<void> _initCartFeature() async {
  // Use Cases
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantity(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));
  sl.registerLazySingleton(() => WatchCart(sl()));

  // Repository - Firestore implementation
  sl.registerLazySingleton<CartRepository>(
    () => FirestoreCartRepositoryImpl(
      authRepository: sl<AuthRepository>(),
      analyticsService: sl<AnalyticsService>(),
    ),
    dispose: (instance) {
      if (instance is FirestoreCartRepositoryImpl) {
        instance.dispose();
      }
    },
  );
}

/// Initialize Address feature dependencies
Future<void> _initAddressFeature() async {
  // Use Cases
  sl.registerLazySingleton(() => WatchAddresses(sl()));
  sl.registerLazySingleton(() => AddAddress(sl()));
  sl.registerLazySingleton(() => UpdateAddress(sl()));
  sl.registerLazySingleton(() => DeleteAddress(sl()));

  // Repository - Firestore implementation
  sl.registerLazySingleton<AddressRepository>(
    () => FirestoreAddressRepositoryImpl(),
  );
}

/// Initialize Order/Checkout feature dependencies
Future<void> _initOrderFeature() async {
  // Use Cases
  sl.registerLazySingleton(() => PlaceOrder(sl()));
  sl.registerLazySingleton(() => WatchUserOrders(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));

  // Repository - Firestore implementation
  sl.registerLazySingleton<OrderRepository>(
    () => FirestoreOrderRepositoryImpl(
      analyticsService: sl<AnalyticsService>(),
    ),
  );
}
