import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/constants/app_strings.dart';
import 'package:cd_shop/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/presentation/bloc/product_detail_bloc.dart';
import 'package:cd_shop/injection_container.dart';

/// Page displaying product details
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProductDetailBloc>()..add(ProductDetailFetched(productId)),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) {
        return switch (state) {
          ProductDetailInitial() ||
          ProductDetailLoading() =>
            Scaffold(
              appBar: AppBar(title: const Text('Product Details')),
              body: const Center(child: CircularProgressIndicator()),
            ),
          ProductDetailNotFound() => Scaffold(
              appBar: AppBar(title: const Text('Product Details')),
              body: const Center(child: Text('Product not found')),
            ),
          ProductDetailError(:final message) => Scaffold(
              appBar: AppBar(title: const Text('Product Details')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          ProductDetailLoaded(:final product) => Scaffold(
              appBar: AppBar(
                title: Text(product.artist),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AlbumArt(product: product),
                    _ProductInfo(product: product),
                  ],
                ),
              ),
              bottomNavigationBar: _AddToCartBar(product: product),
            ),
        };
      },
    );
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 320,
      width: double.infinity,
      child: product.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: product.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildLoadingPlaceholder(theme),
              errorWidget: (context, url, error) => _buildPlaceholder(theme),
            )
          : _buildPlaceholder(theme),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Icon(
          Icons.album,
          size: 160,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ThemeData theme) {
    return ColoredBox(
      color: theme.colorScheme.primaryContainer,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            product.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Artist
          Text(
            product.artist,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Genre and Year
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(product.genreLabel),
                visualDensity: VisualDensity.compact,
              ),
              if (product.releaseYear != null)
                Chip(
                  label: Text(product.releaseYear.toString()),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            product.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Stock info
          Row(
            children: [
              Icon(
                product.isInStock ? Icons.check_circle : Icons.cancel,
                color: product.isInStock ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                product.isInStock
                    ? '${product.stockQuantity} ${AppStrings.inStock}'
                    : AppStrings.outOfStock,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: product.isInStock ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.price,
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),

            // Add to cart button
            Expanded(
              child: FilledButton.icon(
                onPressed: product.isInStock
                    ? () {
                        sl<CartBloc>().add(CartItemAdded(product));
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text(AppStrings.addToCart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
