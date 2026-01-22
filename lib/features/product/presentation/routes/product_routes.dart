import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/product/presentation/pages/product_detail_page.dart';
import 'package:cd_shop/features/product/presentation/pages/product_list_page.dart';
import 'package:cd_shop/features/product/presentation/pages/product_search_page.dart';

/// Route paths for product feature
class ProductRoutes {
  ProductRoutes._();

  static const String home = '/';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String search = '/search';
}

/// Products tab branch (Home)
StatefulShellBranch productBranch() => StatefulShellBranch(
      routes: [
        GoRoute(
          path: ProductRoutes.home,
          name: 'home',
          builder: (context, state) => const ProductListPage(),
          routes: [
            GoRoute(
              path: 'products/:id',
              name: 'productDetail',
              builder: (context, state) {
                final productId = state.pathParameters['id'] ?? '';
                return ProductDetailPage(productId: productId);
              },
            ),
          ],
        ),
      ],
    );

/// Search tab branch
StatefulShellBranch searchBranch() => StatefulShellBranch(
      routes: [
        GoRoute(
          path: ProductRoutes.search,
          name: 'search',
          builder: (context, state) => const ProductSearchPage(),
          routes: [
            GoRoute(
              path: 'products/:id',
              name: 'searchProductDetail',
              builder: (context, state) {
                final productId = state.pathParameters['id'] ?? '';
                return ProductDetailPage(productId: productId);
              },
            ),
          ],
        ),
      ],
    );
