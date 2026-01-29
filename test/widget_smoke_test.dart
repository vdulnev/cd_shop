import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart' hide Disposable;
import 'package:mocktail/mocktail.dart';

import 'package:cd_shop/app.dart';
import 'package:cd_shop/core/models/disposable.dart';
import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/core/services/analytics_observer.dart';
import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/cart/domain/repositories/cart_repository.dart';
import 'package:cd_shop/features/order/domain/repositories/order_repository.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';
import 'package:cd_shop/core/di/dependency_factory.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class MockDependencyFactory implements DependencyFactory {

  MockDependencyFactory() {
    when(() => _analyticsService.observer)
        .thenReturn(MockFirebaseAnalyticsObserver());
  }
  static const _emptyEvents = Stream<RepositoryEvent>.empty();
  final AnalyticsService _analyticsService = MockAnalyticsService();

  @override
  AnalyticsService createAnalyticsService() => _analyticsService;

  @override
  AnalyticsObserver createAnalyticsObserver({
    required AnalyticsService analyticsService,
  }) => AnalyticsObserver(analyticsService: analyticsService);

  @override
  AuthRepository createAuthRepository() {
    final mock = MockAuthRepository();
    when(() => mock.eventStream()).thenAnswer((_) => _emptyEvents);
    when(() => mock.watchCurrentUser())
        .thenAnswer((_) => const Stream<User?>.empty());
    return mock;
  }

  @override
  ProductRepository createProductRepository() {
    final mock = MockProductRepository();
    when(() => mock.eventStream()).thenAnswer((_) => _emptyEvents);
    when(() => mock.watchProducts())
        .thenAnswer((_) => Stream.value(const <Product>[]));
    return mock;
  }

  @override
  CartRepository createCartRepository() {
    final mock = MockCartRepository();
    when(() => mock.eventStream()).thenAnswer((_) => _emptyEvents);
    when(() => mock.watchCart())
        .thenAnswer((_) => const Stream<Cart>.empty());
    return mock;
  }

  @override
  AddressRepository createAddressRepository() {
    final mock = MockAddressRepository();
    when(() => mock.eventStream()).thenAnswer((_) => _emptyEvents);
    return mock;
  }

  @override
  OrderRepository createOrderRepository() {
    final mock = MockOrderRepository();
    when(() => mock.eventStream()).thenAnswer((_) => _emptyEvents);
    return mock;
  }
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initDependencies(factory: MockDependencyFactory());
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Flush pending timers from async DB operations (Floor/sqflite)
    await tester.pump(const Duration(seconds: 10));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
