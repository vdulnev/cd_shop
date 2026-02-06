// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i15;
import 'package:cd_shop/features/address/domain/entities/address.dart' as _i19;
import 'package:cd_shop/features/address/presentation/pages/add_address_page.dart'
    as _i3;
import 'package:cd_shop/features/address/presentation/pages/addresses_page.dart'
    as _i4;
import 'package:cd_shop/features/address/presentation/pages/edit_address_page.dart'
    as _i7;
import 'package:cd_shop/features/auth/presentation/pages/account_page.dart'
    as _i1;
import 'package:cd_shop/features/auth/presentation/pages/login_page.dart'
    as _i8;
import 'package:cd_shop/features/auth/presentation/pages/registration_page.dart'
    as _i14;
import 'package:cd_shop/features/cart/domain/entities/cart_item.dart' as _i17;
import 'package:cd_shop/features/cart/presentation/pages/cart_page.dart' as _i5;
import 'package:cd_shop/features/cart/presentation/pages/checkout_page.dart'
    as _i6;
import 'package:cd_shop/features/order/presentation/pages/orders_page.dart'
    as _i10;
import 'package:cd_shop/features/product/presentation/pages/product_detail_page.dart'
    as _i11;
import 'package:cd_shop/features/product/presentation/pages/product_list_page.dart'
    as _i12;
import 'package:cd_shop/features/product/presentation/pages/product_search_page.dart'
    as _i13;
import 'package:cd_shop/main_page.dart' as _i9;
import 'package:cd_shop/router/tab_pages.dart' as _i2;
import 'package:collection/collection.dart' as _i18;
import 'package:flutter/material.dart' as _i16;

/// generated route for
/// [_i1.AccountPage]
class AccountRoute extends _i15.PageRouteInfo<void> {
  const AccountRoute({List<_i15.PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i1.AccountPage();
    },
  );
}

/// generated route for
/// [_i2.AccountTabPage]
class AccountTab extends _i15.PageRouteInfo<void> {
  const AccountTab({List<_i15.PageRouteInfo>? children})
    : super(AccountTab.name, initialChildren: children);

  static const String name = 'AccountTab';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i2.AccountTabPage();
    },
  );
}

/// generated route for
/// [_i3.AddAddressPage]
class AddAddressRoute extends _i15.PageRouteInfo<void> {
  const AddAddressRoute({List<_i15.PageRouteInfo>? children})
    : super(AddAddressRoute.name, initialChildren: children);

  static const String name = 'AddAddressRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i3.AddAddressPage();
    },
  );
}

/// generated route for
/// [_i4.AddressesPage]
class AddressesRoute extends _i15.PageRouteInfo<void> {
  const AddressesRoute({List<_i15.PageRouteInfo>? children})
    : super(AddressesRoute.name, initialChildren: children);

  static const String name = 'AddressesRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i4.AddressesPage();
    },
  );
}

/// generated route for
/// [_i5.CartPage]
class CartRoute extends _i15.PageRouteInfo<void> {
  const CartRoute({List<_i15.PageRouteInfo>? children})
    : super(CartRoute.name, initialChildren: children);

  static const String name = 'CartRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i5.CartPage();
    },
  );
}

/// generated route for
/// [_i2.CartTabPage]
class CartTab extends _i15.PageRouteInfo<void> {
  const CartTab({List<_i15.PageRouteInfo>? children})
    : super(CartTab.name, initialChildren: children);

  static const String name = 'CartTab';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i2.CartTabPage();
    },
  );
}

/// generated route for
/// [_i6.CheckoutPage]
class CheckoutRoute extends _i15.PageRouteInfo<CheckoutRouteArgs> {
  CheckoutRoute({
    _i16.Key? key,
    required String userId,
    required List<_i17.CartItem> cartItems,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         CheckoutRoute.name,
         args: CheckoutRouteArgs(
           key: key,
           userId: userId,
           cartItems: cartItems,
         ),
         initialChildren: children,
       );

  static const String name = 'CheckoutRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CheckoutRouteArgs>();
      return _i6.CheckoutPage(
        key: args.key,
        userId: args.userId,
        cartItems: args.cartItems,
      );
    },
  );
}

class CheckoutRouteArgs {
  const CheckoutRouteArgs({
    this.key,
    required this.userId,
    required this.cartItems,
  });

  final _i16.Key? key;

  final String userId;

  final List<_i17.CartItem> cartItems;

  @override
  String toString() {
    return 'CheckoutRouteArgs{key: $key, userId: $userId, cartItems: $cartItems}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CheckoutRouteArgs) return false;
    return key == other.key &&
        userId == other.userId &&
        const _i18.ListEquality<_i17.CartItem>().equals(
          cartItems,
          other.cartItems,
        );
  }

  @override
  int get hashCode =>
      key.hashCode ^
      userId.hashCode ^
      const _i18.ListEquality<_i17.CartItem>().hash(cartItems);
}

/// generated route for
/// [_i7.EditAddressPage]
class EditAddressRoute extends _i15.PageRouteInfo<EditAddressRouteArgs> {
  EditAddressRoute({
    _i16.Key? key,
    required _i19.Address address,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         EditAddressRoute.name,
         args: EditAddressRouteArgs(key: key, address: address),
         initialChildren: children,
       );

  static const String name = 'EditAddressRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditAddressRouteArgs>();
      return _i7.EditAddressPage(key: args.key, address: args.address);
    },
  );
}

class EditAddressRouteArgs {
  const EditAddressRouteArgs({this.key, required this.address});

  final _i16.Key? key;

  final _i19.Address address;

  @override
  String toString() {
    return 'EditAddressRouteArgs{key: $key, address: $address}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditAddressRouteArgs) return false;
    return key == other.key && address == other.address;
  }

  @override
  int get hashCode => key.hashCode ^ address.hashCode;
}

/// generated route for
/// [_i8.LoginPage]
class LoginRoute extends _i15.PageRouteInfo<void> {
  const LoginRoute({List<_i15.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i8.LoginPage();
    },
  );
}

/// generated route for
/// [_i9.MainPage]
class MainRoute extends _i15.PageRouteInfo<void> {
  const MainRoute({List<_i15.PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i9.MainPage();
    },
  );
}

/// generated route for
/// [_i10.OrdersPage]
class OrdersRoute extends _i15.PageRouteInfo<OrdersRouteArgs> {
  OrdersRoute({
    _i16.Key? key,
    required String userId,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         OrdersRoute.name,
         args: OrdersRouteArgs(key: key, userId: userId),
         initialChildren: children,
       );

  static const String name = 'OrdersRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OrdersRouteArgs>();
      return _i10.OrdersPage(key: args.key, userId: args.userId);
    },
  );
}

class OrdersRouteArgs {
  const OrdersRouteArgs({this.key, required this.userId});

  final _i16.Key? key;

  final String userId;

  @override
  String toString() {
    return 'OrdersRouteArgs{key: $key, userId: $userId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OrdersRouteArgs) return false;
    return key == other.key && userId == other.userId;
  }

  @override
  int get hashCode => key.hashCode ^ userId.hashCode;
}

/// generated route for
/// [_i11.ProductDetailPage]
class ProductDetailRoute extends _i15.PageRouteInfo<ProductDetailRouteArgs> {
  ProductDetailRoute({
    _i16.Key? key,
    required String productId,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         ProductDetailRoute.name,
         args: ProductDetailRouteArgs(key: key, productId: productId),
         rawPathParams: {'id': productId},
         initialChildren: children,
       );

  static const String name = 'ProductDetailRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ProductDetailRouteArgs>(
        orElse: () =>
            ProductDetailRouteArgs(productId: pathParams.getString('id')),
      );
      return _i11.ProductDetailPage(key: args.key, productId: args.productId);
    },
  );
}

class ProductDetailRouteArgs {
  const ProductDetailRouteArgs({this.key, required this.productId});

  final _i16.Key? key;

  final String productId;

  @override
  String toString() {
    return 'ProductDetailRouteArgs{key: $key, productId: $productId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProductDetailRouteArgs) return false;
    return key == other.key && productId == other.productId;
  }

  @override
  int get hashCode => key.hashCode ^ productId.hashCode;
}

/// generated route for
/// [_i12.ProductListPage]
class ProductListRoute extends _i15.PageRouteInfo<void> {
  const ProductListRoute({List<_i15.PageRouteInfo>? children})
    : super(ProductListRoute.name, initialChildren: children);

  static const String name = 'ProductListRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i12.ProductListPage();
    },
  );
}

/// generated route for
/// [_i13.ProductSearchPage]
class ProductSearchRoute extends _i15.PageRouteInfo<void> {
  const ProductSearchRoute({List<_i15.PageRouteInfo>? children})
    : super(ProductSearchRoute.name, initialChildren: children);

  static const String name = 'ProductSearchRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i13.ProductSearchPage();
    },
  );
}

/// generated route for
/// [_i2.ProductsTabPage]
class ProductsTab extends _i15.PageRouteInfo<void> {
  const ProductsTab({List<_i15.PageRouteInfo>? children})
    : super(ProductsTab.name, initialChildren: children);

  static const String name = 'ProductsTab';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i2.ProductsTabPage();
    },
  );
}

/// generated route for
/// [_i14.RegistrationPage]
class RegistrationRoute extends _i15.PageRouteInfo<void> {
  const RegistrationRoute({List<_i15.PageRouteInfo>? children})
    : super(RegistrationRoute.name, initialChildren: children);

  static const String name = 'RegistrationRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i14.RegistrationPage();
    },
  );
}

/// generated route for
/// [_i2.SearchTabPage]
class SearchTab extends _i15.PageRouteInfo<void> {
  const SearchTab({List<_i15.PageRouteInfo>? children})
    : super(SearchTab.name, initialChildren: children);

  static const String name = 'SearchTab';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i2.SearchTabPage();
    },
  );
}
