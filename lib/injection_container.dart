import 'package:get_it/get_it.dart';

import 'package:cd_shop/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';
import 'package:cd_shop/features/auth/presentation/bloc/account_bloc.dart';
import 'package:cd_shop/features/auth/presentation/bloc/login_bloc.dart';
import 'package:cd_shop/features/auth/presentation/bloc/registration_bloc.dart';
import 'package:cd_shop/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/get_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:cd_shop/features/product/data/repositories/product_repository_impl.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_detail_bloc.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_list_bloc.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_search_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// Call this function in main() before runApp()
Future<void> initDependencies() async {
  // ===== Features =====
  await _initAuthFeature();
  await _initProductFeature();
  await _initCartFeature();
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

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
}

/// Initialize Product feature dependencies
Future<void> _initProductFeature() async {
  // Bloc
  sl.registerFactory(() => ProductListBloc(getProducts: sl()));
  sl.registerFactory(() => ProductSearchBloc(searchProducts: sl()));
  sl.registerFactory(() => ProductDetailBloc(getProductById: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetProducts(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));
  sl.registerLazySingleton(() => GetProductById(sl()));

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(),
  );
}

/// Initialize Cart feature dependencies
Future<void> _initCartFeature() async {
  // Bloc - registered as singleton so cart state persists across pages
  sl.registerFactory(
    () => CartBloc(
      getCart: sl(),
      addToCart: sl(),
      removeFromCart: sl(),
      updateCartQuantity: sl(),
      clearCart: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCart(sl()));
  sl.registerLazySingleton(() => AddToCart(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantity(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));

  // Repositories
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(),
  );
}
