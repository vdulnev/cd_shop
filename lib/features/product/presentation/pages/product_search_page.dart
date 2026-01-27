import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_search_state.dart';
import 'package:cd_shop/features/product/presentation/providers/product_search_provider.dart';

class ProductSearchPage extends ConsumerStatefulWidget {
  const ProductSearchPage({super.key});

  @override
  ConsumerState<ProductSearchPage> createState() => _ProductSearchViewState();
}

class _ProductSearchViewState extends ConsumerState<ProductSearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(productSearchProvider.notifier).updateQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(productSearchProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search albums...',
            border: InputBorder.none,
            suffixIcon: switch (state) {
              ProductSearchLoaded(:final query) when query.isNotEmpty => IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                ),
              _ => const SizedBox.shrink(),
            },
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: switch (state) {
        ProductSearchInitial() => const _EmptySearchView(),
        ProductSearchLoading() => const Center(child: CircularProgressIndicator()),
        ProductSearchLoaded(:final products, :final query) =>
          products.isEmpty
              ? _NoResultsView(query: query)
              : _SearchResultsList(products: products),
      },
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for albums',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  const _NoResultsView({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$query"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _SearchResultItem(
          product: product,
          onTap: () => context.push('/search/products/${product.id}'),
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  const _SearchResultItem({
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 56,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: product.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: product.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(theme),
                  errorWidget: (context, url, error) => _buildPlaceholder(theme),
                )
              : _buildPlaceholder(theme),
        ),
      ),
      title: Text(
        product.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        product.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '\$${product.price.toStringAsFixed(2)}',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.album,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
