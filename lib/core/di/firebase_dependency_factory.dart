import 'package:cd_shop/core/database/app_database.dart';
import 'package:cd_shop/core/di/dependency_factory.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/features/address/data/repositories/firestore_address_repository_impl.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/auth/data/repositories/firebase_auth_repository_impl.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/data/repositories/firestore_cart_repository_impl.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/order/data/repositories/firestore_order_repository_impl.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/data/repositories/firestore_product_repository_impl.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/injection_container.dart';

/// Default factory that creates real Firebase-backed dependencies.
class FirebaseDependencyFactory implements DependencyFactory {
  @override
  AuthRepository createAuthRepository() => FirebaseAuthRepositoryImpl(
        analyticsEventBus: sl<AnalyticsEventBus>(),
      );

  @override
  ProductRepository createProductRepository() =>
      FirestoreProductRepositoryImpl(
        productDao: sl<AppDatabase>().productDao,
      );

  @override
  CartRepository createCartRepository() => FirestoreCartRepositoryImpl(
        authRepository: sl<AuthRepository>(),
        analyticsEventBus: sl<AnalyticsEventBus>(),
      );

  @override
  AddressRepository createAddressRepository() =>
      FirestoreAddressRepositoryImpl();

  @override
  OrderRepository createOrderRepository() => FirestoreOrderRepositoryImpl(
        analyticsEventBus: sl<AnalyticsEventBus>(),
      );
}
