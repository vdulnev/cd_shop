import 'package:get_it/get_it.dart';

import 'package:cd_shop/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';
import 'package:cd_shop/features/auth/presentation/bloc/login_bloc.dart';
import 'package:cd_shop/features/auth/presentation/bloc/registration_bloc.dart';
import 'package:cd_shop/features/product/data/repositories/product_repository_impl.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_list_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// Call this function in main() before runApp()
Future<void> initDependencies() async {
  // ===== Features =====
  await _initAuthFeature();
  await _initProductFeature();
}

/// Initialize Auth feature dependencies
Future<void> _initAuthFeature() async {
  // Bloc
  sl.registerFactory(() => LoginBloc(loginUser: sl()));
  sl.registerFactory(() => RegistrationBloc(registerUser: sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUser(sl()));
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

  // Use Cases
  sl.registerLazySingleton(() => GetProducts(sl()));

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(),
  );
}
