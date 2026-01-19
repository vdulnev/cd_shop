import 'package:flutter/material.dart';

import 'package:cd_shop/core/constants/app_strings.dart';

/// Page displaying product details
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.album,
              size: 120,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'Product ID: $productId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Product details will be displayed here',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Add to cart functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to cart!'),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text(AppStrings.addToCart),
            ),
          ],
        ),
      ),
    );
  }
}
