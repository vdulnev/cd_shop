import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart' hide Disposable;
import 'package:mocktail/mocktail.dart';

import 'package:cd_shop/app.dart';
import 'package:cd_shop/core/models/disposable.dart';
import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:talker/talker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/features/address/domain/usecases/add_address.dart';
import 'package:cd_shop/features/address/domain/usecases/delete_address.dart';
import 'package:cd_shop/features/address/domain/usecases/update_address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/login_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/logout_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/register_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/set_default_address.dart';
import 'package:cd_shop/features/auth/domain/usecases/watch_current_user.dart';
import 'package:cd_shop/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/clear_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cd_shop/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:cd_shop/features/cart/domain/usecases/watch_cart.dart';
import 'package:cd_shop/features/order/domain/usecases/cancel_order.dart';
import 'package:cd_shop/features/order/domain/usecases/place_order.dart';
import 'package:cd_shop/features/order/domain/usecases/watch_user_orders.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/domain/usecases/get_products.dart';
import 'package:cd_shop/features/product/domain/usecases/search_products.dart';
import 'package:cd_shop/features/product/domain/usecases/watch_products.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockFirebaseAnalyticsObserver extends Mock
    implements FirebaseAnalyticsObserver {}

class MockAuthRepository extends Mock
    implements AuthRepository, EventEmitter, Disposable {}

class MockProductRepository extends Mock
    implements ProductRepository, EventEmitter, Disposable {}

class MockCartRepository extends Mock
    implements CartRepository, EventEmitter, Disposable {}

class MockAddressRepository extends Mock
    implements AddressRepository, EventEmitter, Disposable {}

class MockOrderRepository extends Mock
    implements OrderRepository, EventEmitter, Disposable {}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await GetIt.instance.reset();

    // Register Mocks directly
    final sl = GetIt.instance;
    sl.allowReassignment = true;

    // Core
    sl.registerSingleton<Talker>(
      Talker(settings: TalkerSettings(enabled: false)),
    );
    final analyticsService = MockAnalyticsService();
    when(
      () => analyticsService.observer,
    ).thenReturn(MockFirebaseAnalyticsObserver());
    sl.registerSingleton<AnalyticsService>(analyticsService);

    // Repositories
    final authRepo = MockAuthRepository();
    final productRepo = MockProductRepository();
    final cartRepo = MockCartRepository();
    final addressRepo = MockAddressRepository();
    final orderRepo = MockOrderRepository();

    const emptyEvents = Stream<RepositoryEvent>.empty();

    // Stub Auth
    when(() => authRepo.eventStream()).thenAnswer((_) => emptyEvents);
    when(
      () => authRepo.watchCurrentUser(),
    ).thenAnswer((_) => const Stream.empty());

    // Stub Product
    when(() => productRepo.eventStream()).thenAnswer((_) => emptyEvents);
    when(() => productRepo.watchProducts()).thenAnswer((_) => Stream.value([]));

    // Stub Cart
    when(() => cartRepo.eventStream()).thenAnswer((_) => emptyEvents);
    when(() => cartRepo.watchCart()).thenAnswer((_) => const Stream.empty());

    // Stub Address
    when(() => addressRepo.eventStream()).thenAnswer((_) => emptyEvents);

    // Stub Order
    when(() => orderRepo.eventStream()).thenAnswer((_) => emptyEvents);

    sl.registerSingleton<AuthRepository>(authRepo);
    sl.registerSingleton<ProductRepository>(productRepo);
    sl.registerSingleton<CartRepository>(cartRepo);
    sl.registerSingleton<AddressRepository>(addressRepo);
    sl.registerSingleton<OrderRepository>(orderRepo);

    // Auth UseCases
    sl.registerLazySingleton<WatchCurrentUser>(
      () => WatchCurrentUserImpl(authRepo),
    );
    sl.registerLazySingleton<GetCurrentUser>(
      () => GetCurrentUserImpl(authRepo),
    );
    sl.registerLazySingleton<LoginUser>(() => LoginUserImpl(authRepo));
    sl.registerLazySingleton<LogoutUser>(() => LogoutUserImpl(authRepo));
    sl.registerLazySingleton<RegisterUser>(() => RegisterUserImpl(authRepo));
    sl.registerLazySingleton<SetDefaultAddress>(
      () => SetDefaultAddressImpl(authRepo),
    );

    // Product UseCases
    sl.registerLazySingleton<GetProducts>(() => GetProductsImpl(productRepo));
    sl.registerLazySingleton<WatchProducts>(
      () => WatchProductsImpl(productRepo),
    );
    sl.registerLazySingleton<SearchProducts>(
      () => SearchProductsImpl(productRepo),
    );
    sl.registerLazySingleton<GetProductById>(
      () => GetProductByIdImpl(productRepo),
    );

    // Cart UseCases
    sl.registerLazySingleton<WatchCart>(() => WatchCartImpl(cartRepo));
    sl.registerLazySingleton<AddToCart>(() => AddToCartImpl(cartRepo));
    sl.registerLazySingleton<UpdateCartQuantity>(
      () => UpdateCartQuantityImpl(cartRepo),
    );
    sl.registerLazySingleton<RemoveFromCart>(
      () => RemoveFromCartImpl(cartRepo),
    );
    sl.registerLazySingleton<ClearCart>(() => ClearCartImpl(cartRepo));

    // Address UseCases
    sl.registerLazySingleton<WatchAddresses>(
      () => WatchAddressesImpl(addressRepo),
    );
    sl.registerLazySingleton<AddAddress>(() => AddAddressImpl(addressRepo));
    sl.registerLazySingleton<UpdateAddress>(
      () => UpdateAddressImpl(addressRepo),
    );
    sl.registerLazySingleton<DeleteAddress>(
      () => DeleteAddressImpl(addressRepo),
    );

    // Order UseCases
    sl.registerLazySingleton<PlaceOrder>(() => PlaceOrderImpl(orderRepo));
    sl.registerLazySingleton<WatchUserOrders>(
      () => WatchUserOrdersImpl(orderRepo),
    );
    sl.registerLazySingleton<CancelOrder>(() => CancelOrderImpl(orderRepo));

    // We do NOT call initDependencies() to avoid real Firebase init
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Flush pending timers from async operations
    await tester.pump(const Duration(seconds: 10));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
