// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_analytics/firebase_analytics.dart' as _i398;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:talker/talker.dart' as _i993;

import 'core/di/register_module.dart' as _i854;
import 'core/services/analytics_observer.dart' as _i220;
import 'core/services/analytics_service.dart' as _i661;
import 'features/address/data/repositories/firestore_address_repository_impl.dart'
    as _i673;
import 'features/address/domain/repositories/address_repository.dart' as _i535;
import 'features/address/domain/usecases/add_address.dart' as _i416;
import 'features/address/domain/usecases/delete_address.dart' as _i42;
import 'features/address/domain/usecases/update_address.dart' as _i855;
import 'features/address/domain/usecases/watch_addresses.dart' as _i140;
import 'features/auth/data/repositories/firebase_auth_repository_impl.dart'
    as _i98;
import 'features/auth/domain/repositories/auth_repository.dart' as _i1015;
import 'features/auth/domain/usecases/get_current_user.dart' as _i191;
import 'features/auth/domain/usecases/login_user.dart' as _i1073;
import 'features/auth/domain/usecases/logout_user.dart' as _i657;
import 'features/auth/domain/usecases/register_user.dart' as _i14;
import 'features/auth/domain/usecases/set_default_address.dart' as _i778;
import 'features/auth/domain/usecases/sign_in_with_apple.dart' as _i78;
import 'features/auth/domain/usecases/sign_in_with_google.dart' as _i648;
import 'features/auth/domain/usecases/watch_current_user.dart' as _i227;
import 'features/cart/data/repositories/firestore_cart_repository_impl.dart'
    as _i589;
import 'features/cart/domain/repositories/cart_repository.dart' as _i303;
import 'features/cart/domain/usecases/add_to_cart.dart' as _i841;
import 'features/cart/domain/usecases/clear_cart.dart' as _i505;
import 'features/cart/domain/usecases/remove_from_cart.dart' as _i905;
import 'features/cart/domain/usecases/update_cart_quantity.dart' as _i381;
import 'features/cart/domain/usecases/watch_cart.dart' as _i244;
import 'features/order/data/repositories/firestore_order_repository_impl.dart'
    as _i28;
import 'features/order/domain/repositories/order_repository.dart' as _i608;
import 'features/order/domain/usecases/cancel_order.dart' as _i932;
import 'features/order/domain/usecases/place_order.dart' as _i560;
import 'features/order/domain/usecases/watch_user_orders.dart' as _i919;
import 'features/product/data/repositories/firestore_product_repository_impl.dart'
    as _i944;
import 'features/product/domain/repositories/product_repository.dart' as _i841;
import 'features/product/domain/usecases/get_product_by_id.dart' as _i305;
import 'features/product/domain/usecases/get_products.dart' as _i591;
import 'features/product/domain/usecases/search_products.dart' as _i653;
import 'features/product/domain/usecases/watch_products.dart' as _i676;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i993.Talker>(() => registerModule.talker);
    gh.singleton<_i398.FirebaseAnalytics>(
      () => registerModule.firebaseAnalytics,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => registerModule.firestore);
    gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.lazySingleton<_i1015.AuthRepository>(
      () => _i98.FirebaseAuthRepositoryImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i191.GetCurrentUser>(
      () => _i191.GetCurrentUserImpl(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i303.CartRepository>(
      () => _i589.FirestoreCartRepositoryImpl(
        authRepository: gh<_i1015.AuthRepository>(),
        firestore: gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i657.LogoutUser>(
      () => _i657.LogoutUserImpl(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i648.SignInWithGoogle>(
      () => _i648.SignInWithGoogleImpl(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i78.SignInWithApple>(
      () => _i78.SignInWithAppleImpl(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i1073.LoginUser>(
      () => _i1073.LoginUserImpl(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i778.SetDefaultAddress>(
      () => _i778.SetDefaultAddressImpl(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i505.ClearCart>(
      () => _i505.ClearCartImpl(gh<_i303.CartRepository>()),
    );
    gh.lazySingleton<_i661.AnalyticsService>(
      () => _i661.AnalyticsService(gh<_i398.FirebaseAnalytics>()),
    );
    gh.lazySingleton<_i227.WatchCurrentUser>(
      () => _i227.WatchCurrentUserImpl(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i841.AddToCart>(
      () => _i841.AddToCartImpl(gh<_i303.CartRepository>()),
    );
    gh.lazySingleton<_i905.RemoveFromCart>(
      () => _i905.RemoveFromCartImpl(gh<_i303.CartRepository>()),
    );
    gh.lazySingleton<_i381.UpdateCartQuantity>(
      () => _i381.UpdateCartQuantityImpl(gh<_i303.CartRepository>()),
    );
    gh.lazySingleton<_i244.WatchCart>(
      () => _i244.WatchCartImpl(gh<_i303.CartRepository>()),
    );
    gh.lazySingleton<_i608.OrderRepository>(
      () => _i28.FirestoreOrderRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i841.ProductRepository>(
      () => _i944.FirestoreProductRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i220.AnalyticsObserver>(
      () => _i220.AnalyticsObserver(
        gh<_i661.AnalyticsService>(),
        gh<_i1015.AuthRepository>(),
        gh<_i303.CartRepository>(),
        gh<_i608.OrderRepository>(),
        gh<_i841.ProductRepository>(),
      ),
    );
    gh.lazySingleton<_i535.AddressRepository>(
      () => _i673.FirestoreAddressRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i14.RegisterUser>(
      () => _i14.RegisterUserImpl(gh<_i1015.AuthRepository>()),
    );
    gh.lazySingleton<_i653.SearchProducts>(
      () => _i653.SearchProductsImpl(gh<_i841.ProductRepository>()),
    );
    gh.lazySingleton<_i591.GetProducts>(
      () => _i591.GetProductsImpl(gh<_i841.ProductRepository>()),
    );
    gh.lazySingleton<_i416.AddAddress>(
      () => _i416.AddAddressImpl(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i42.DeleteAddress>(
      () => _i42.DeleteAddressImpl(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i855.UpdateAddress>(
      () => _i855.UpdateAddressImpl(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i140.WatchAddresses>(
      () => _i140.WatchAddressesImpl(gh<_i535.AddressRepository>()),
    );
    gh.lazySingleton<_i305.GetProductById>(
      () => _i305.GetProductByIdImpl(gh<_i841.ProductRepository>()),
    );
    gh.lazySingleton<_i932.CancelOrder>(
      () => _i932.CancelOrderImpl(gh<_i608.OrderRepository>()),
    );
    gh.lazySingleton<_i676.WatchProducts>(
      () => _i676.WatchProductsImpl(gh<_i841.ProductRepository>()),
    );
    gh.lazySingleton<_i919.WatchUserOrders>(
      () => _i919.WatchUserOrdersImpl(gh<_i608.OrderRepository>()),
    );
    gh.lazySingleton<_i560.PlaceOrder>(
      () => _i560.PlaceOrderImpl(gh<_i608.OrderRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i854.RegisterModule {}
