import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/presentation/pages/add_address_page.dart';
import 'package:cd_shop/features/address/presentation/pages/addresses_page.dart';
import 'package:cd_shop/features/address/presentation/pages/edit_address_page.dart';

/// Route paths for address feature
class AddressRoutes {
  AddressRoutes._();

  static const String addresses = 'addresses';
  static const String addAddress = 'add';
  static const String editAddress = ':id/edit';
}

/// Address routes
List<RouteBase> addressRoutes() => [
      GoRoute(
        path: AddressRoutes.addresses,
        name: 'addresses',
        builder: (context, state) => const AddressesPage(),
        routes: [
          GoRoute(
            path: AddressRoutes.addAddress,
            name: 'add_address',
            builder: (context, state) => const AddAddressPage(),
          ),
          GoRoute(
            path: AddressRoutes.editAddress,
            name: 'edit_address',
            builder: (context, state) {
              final address = state.extra as Address?;
              if (address == null) {
                throw Exception('Address not provided for edit');
              }
              return EditAddressPage(address: address);
            },
          ),
        ],
      ),
    ];
