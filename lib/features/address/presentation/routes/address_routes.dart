import 'package:auto_route/auto_route.dart';

import 'package:cd_shop/router/app_router.gr.dart';

final addressRoutes = [
  AutoRoute(path: 'addresses', page: AddressesRoute.page),
  AutoRoute(path: 'addresses/add', page: AddAddressRoute.page),
  AutoRoute(path: 'addresses/edit', page: EditAddressRoute.page),
];
