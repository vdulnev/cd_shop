import 'package:get_it/get_it.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// Call this function in main() before runApp()
Future<void> initDependencies() async {
  // ===== External =====
  // Register external dependencies like Dio, SharedPreferences, etc.
  // Example:
  // sl.registerLazySingleton(() => Dio());

  // ===== Core =====
  // Register core services

  // ===== Features =====
  await _initProductFeature();
  // await _initCartFeature();
  // await _initAuthFeature();
}

/// Initialize Product feature dependencies
Future<void> _initProductFeature() async {
  // BLoC / Cubit
  // sl.registerFactory(
  //   () => ProductBloc(getProducts: sl()),
  // );

  // Use Cases
  // sl.registerLazySingleton(() => GetProducts(sl()));
  // sl.registerLazySingleton(() => GetProductDetails(sl()));

  // Repositories
  // sl.registerLazySingleton<ProductRepository>(
  //   () => ProductRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //   ),
  // );

  // Data Sources
  // sl.registerLazySingleton<ProductRemoteDataSource>(
  //   () => ProductRemoteDataSourceImpl(client: sl()),
  // );
}

// /// Initialize Cart feature dependencies
// Future<void> _initCartFeature() async {
//   // Cubit
//   sl.registerFactory(() => CartCubit());
// }

// /// Initialize Auth feature dependencies
// Future<void> _initAuthFeature() async {
//   // BLoC
//   // sl.registerFactory(() => AuthBloc(login: sl(), logout: sl()));
// }
