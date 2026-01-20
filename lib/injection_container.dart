import 'package:get_it/get_it.dart';

import 'package:cd_shop/features/product/data/repositories/product_repository_impl.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// Call this function in main() before runApp()
Future<void> initDependencies() async {
  // ===== Features =====
  await _initProductFeature();
}

/// Initialize Product feature dependencies
Future<void> _initProductFeature() async {
  // Use Cases
  sl.registerLazySingleton(() => GetProducts(sl()));

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(),
  );
}
