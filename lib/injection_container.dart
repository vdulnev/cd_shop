import 'package:get_it/get_it.dart';

import 'package:cd_shop/core/blocs/app_event_bloc.dart';
import 'package:cd_shop/core/database/app_database.dart';
import 'package:cd_shop/features/address/data/repositories/address_repository_impl.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/address/domain/usecases/add_address.dart';
import 'package:cd_shop/features/address/domain/usecases/delete_address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/address/domain/usecases/update_address.dart';
import 'package:cd_shop/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/set_default_address.dart';
import 'package:cd_shop/features/auth/presentation/bloc/account_bloc.dart';
import 'package:cd_shop/features/auth/presentation/bloc/login_bloc.dart';
import 'package:cd_shop/features/auth/presentation/bloc/registration_bloc.dart';
import 'package:cd_shop/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/cart/domain/usecases/watch_cart.dart';
import 'package:cd_shop/features/order/data/repositories/order_repository_impl.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/order/domain/usecases/cancel_order.dart';
import 'package:cd_shop/features/order/domain/usecases/place_order.dart';
import 'package:cd_shop/features/order/domain/usecases/watch_user_orders.dart';
import 'package:cd_shop/features/order/presentation/bloc/checkout_bloc.dart';
import 'package:cd_shop/features/order/presentation/bloc/order_list_bloc.dart';
import 'package:cd_shop/features/product/data/repositories/product_repository_impl.dart';
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
  // ===== Core (Database) =====
  await _initDatabase();

  // ===== Features =====
  await _initAuthFeature();
  await _initProductFeature();
  await _initCartFeature();
  await _initAddressFeature();
  await _initOrderFeature();

  // ===== Core (App-level) =====
  _initCoreBlocs();
}

/// Initialize database
Future<void> _initDatabase() async {
  final database = await AppDatabase.create();
  sl.registerSingleton<AppDatabase>(database);
}

/// Initialize Auth feature dependencies
Future<void> _initAuthFeature() async {
  // Bloc
  sl.registerFactory(
    () => AccountBloc(getCurrentUser: sl(), logoutUser: sl()),
  );
  sl.registerFactory(() => LoginBloc(loginUser: sl()));
  sl.registerFactory(() => RegistrationBloc(registerUser: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => SetDefaultAddress(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(userDao: sl<AppDatabase>().userDao),
  );
}

/// Initialize Product feature dependencies
Future<void> _initProductFeature() async {
  // Use Cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => GetProductById(sl()));
  sl.registerLazySingleton(() => WatchProducts(sl()));

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      productDao: sl<AppDatabase>().productDao,
      appSettingsDao: sl<AppDatabase>().appSettingsDao,
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

  // Repositories
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      cartDao: sl<AppDatabase>().cartDao,
      authRepository: sl(),
    ),
  );
}

/// Initialize Address feature dependencies
Future<void> _initAddressFeature() async {
  // Use Cases
  sl.registerLazySingleton(() => WatchAddresses(sl()));
  sl.registerLazySingleton(() => AddAddress(sl()));
  sl.registerLazySingleton(() => UpdateAddress(sl()));
  sl.registerLazySingleton(() => DeleteAddress(sl()));

  // Repositories
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(sl<AppDatabase>().addressDao),
  );
}

/// Initialize Order/Checkout feature dependencies
Future<void> _initOrderFeature() async {
  // Bloc
  sl.registerFactory(
    () => CheckoutBloc(
      watchAddresses: sl(),
      placeOrder: sl(),
      clearCart: sl(),
    ),
  );
  sl.registerFactory(
    () => OrderListBloc(
      watchUserOrders: sl(),
      cancelOrder: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => PlaceOrder(sl()));
  sl.registerLazySingleton(() => WatchUserOrders(sl()));
  sl.registerLazySingleton(() => CancelOrder(sl()));

  // Repositories
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      orderDao: sl<AppDatabase>().orderDao,
      addressDao: sl<AppDatabase>().addressDao,
    ),
  );
}

/// Initialize core (app-level) BLoCs
void _initCoreBlocs() {
  sl.registerFactory(
    () => AppEventBloc(
      addressRepository: sl(),
      authRepository: sl(),
      cartRepository: sl(),
      productRepository: sl(),
      orderRepository: sl(),
    ),
  );
}
