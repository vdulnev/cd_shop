import 'package:flutter/material.dart';

import 'package:cd_shop/core/constants/app_strings.dart';
import 'package:cd_shop/features/product/data/datasources/product_mock_datasource.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';

/// Page displaying product details
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    final product = ProductMockDataSource.getById(productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
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
    );
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 280,
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
              if (product.genre != null)
                Chip(
                  label: Text(product.genre!),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to cart!'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {},
                            ),
                          ),
                        );
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
