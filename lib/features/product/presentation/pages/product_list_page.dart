import 'package:flutter/material.dart';

import 'package:cd_shop/core/constants/app_strings.dart';

/// Page displaying the list of products
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // TODO: Navigate to cart
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to CD Shop!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Products will be displayed here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use with BLoC (uncomment when BLoC is wired up):
//
// class ProductListPage extends StatelessWidget {
//   const ProductListPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => sl<ProductBloc>()..add(const LoadProducts()),
//       child: Scaffold(
//         appBar: AppBar(title: const Text(AppStrings.appName)),
//         body: BlocBuilder<ProductBloc, ProductState>(
//           builder: (context, state) {
//             return switch (state) {
//               ProductInitial() => const SizedBox.shrink(),
//               ProductLoading() => const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               ProductLoaded(:final products) => ListView.builder(
//                   itemCount: products.length,
//                   itemBuilder: (context, index) {
//                     final product = products[index];
//                     return ProductCard(product: product);
//                   },
//                 ),
//               ProductError(:final message) => Center(
//                   child: Text(message),
//                 ),
//             };
//           },
//         ),
//       ),
//     );
//   }
// }
