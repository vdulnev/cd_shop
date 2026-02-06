import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/core/constants/app_strings.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/presentation/providers/product_list_state.dart';
import 'package:cd_shop/features/product/presentation/providers/product_list_provider.dart';
import 'package:cd_shop/router/app_router.gr.dart';

/// Page displaying the list of products
@RoutePage()
class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productListProvider);
    final notifier = ref.read(productListProvider.notifier);

    return _ProductListView(
      state: state,
      onRefresh: notifier.refresh,
    );
  }
}

class _ProductListView extends StatelessWidget {
  const _ProductListView({
    required this.state,
    required this.onRefresh,
  });

  final ProductListState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.tabsRouter.setActiveIndex(2),
          ),
        ],
      ),
      body: switch (state) {
        ProductListInitial() || ProductListLoading() =>
          const Center(child: CircularProgressIndicator()),
        ProductListLoaded(:final products) => _ProductGrid(
            products: products,
            onRefresh: onRefresh,
          ),
      },
    );
  }
}

// No explicit error view; errors surface via app events/snackbars

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.onRefresh});

  final List<Product> products;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductCard(
            product: product,
            onTap: () => context.router.push(ProductDetailRoute(productId: product.id)),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album art
            Expanded(
              flex: 3,
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildLoadingPlaceholder(theme),
                      errorWidget: (context, url, error) => _buildPlaceholder(theme),
                    )
                  : _buildPlaceholder(theme),
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.artist,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                      '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.album,
          size: 64,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.primaryContainer,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
