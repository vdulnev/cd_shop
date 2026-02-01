import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/cart/domain/entities/cart_item.dart';
import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/presentation/providers/checkout_state.dart';
import 'package:cd_shop/features/order/presentation/providers/checkout_provider.dart';
import 'package:cd_shop/features/order/presentation/widgets/address_selection_section.dart';
import 'package:cd_shop/features/order/presentation/widgets/order_summary_section.dart';
import 'package:cd_shop/features/order/presentation/widgets/payment_method_section.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({
    super.key,
    required this.userId,
    required this.cartItems,
  });

  final String userId;
  final List<CartItem> cartItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (userId: userId, cartItems: cartItems);

    ref.listen<CheckoutState>(checkoutProvider(params), (previous, state) {
      if (state is CheckoutSuccess) {
        _showSuccessDialog(context, state.order);
      } else if (state is CheckoutError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final state = ref.watch(checkoutProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: switch (state) {
        CheckoutInitial() || CheckoutLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        CheckoutReady() => _buildCheckoutForm(context, ref, params, state),
        CheckoutPlacingOrder() => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Placing your order...'),
              ],
            ),
          ),
        CheckoutSuccess() => const SizedBox.shrink(),
        CheckoutError() => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
      },
    );
  }

  Widget _buildCheckoutForm(
    BuildContext context,
    WidgetRef ref,
    ({String userId, List<CartItem> cartItems}) params,
    CheckoutReady state,
  ) {
    if (state.cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 64),
            const SizedBox(height: 16),
            const Text('Your cart is empty'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Address Selection
          AddressSelectionSection(
            addresses: state.addresses,
            selectedAddress: state.selectedAddress,
            onAddressSelected: (address) {
              ref
                  .read(checkoutProvider(params).notifier)
                  .selectAddress(address);
            },
          ),

          const Divider(height: 1),

          // Payment Method
          PaymentMethodSection(
            selectedPaymentMethod: state.selectedPaymentMethod,
            onPaymentMethodSelected: (method) {
              ref
                  .read(checkoutProvider(params).notifier)
                  .selectPaymentMethod(method);
            },
          ),

          const Divider(height: 1),

          // Order Notes
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Order Notes (Optional)',
                hintText: 'Any special instructions for your order',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (notes) {
                ref.read(checkoutProvider(params).notifier).updateNotes(notes);
              },
            ),
          ),

          const Divider(height: 1),

          // Order Summary
          OrderSummarySection(
            items: state.cartItems,
            subtotal: state.subtotal,
            shippingCost: state.shippingCost,
            tax: state.tax,
            total: state.total,
          ),

          // Place Order Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: state.canPlaceOrder
                  ? () {
                      ref.read(checkoutProvider(params).notifier).placeOrder();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Place Order - \$${state.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Order Placed!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been placed successfully.'),
            const SizedBox(height: 16),
            Text('Order ID: ${order.id.substring(0, 8)}...'),
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
            if (order.estimatedDeliveryDate != null)
              Text(
                'Estimated Delivery: ${_formatDate(order.estimatedDeliveryDate!)}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

