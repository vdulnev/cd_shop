import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/features/order/domain/entities/order.dart';
import 'package:cd_shop/features/order/presentation/providers/order_list_state.dart';
import 'package:cd_shop/features/order/presentation/providers/order_list_provider.dart';
import 'package:cd_shop/features/order/presentation/widgets/order_card.dart';

@RoutePage()
class OrdersPage extends ConsumerWidget {
  const OrdersPage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderListProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: switch (state) {
        OrderListInitial() || OrderListLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        OrderListError(:final message) => _OrdersErrorView(message: message),
        OrderListLoaded(:final orders) => orders.isEmpty
            ? const _OrdersEmptyView()
            : _OrdersListView(
                orders: orders,
                onCancel: (orderId) =>
                    ref.read(orderListProvider(userId).notifier).cancelOrder(
                          orderId,
                        ),
              ),
      },
    );
  }
}

class _OrdersEmptyView extends StatelessWidget {
  const _OrdersEmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 96,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersErrorView extends StatelessWidget {
  const _OrdersErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersListView extends StatelessWidget {
  const _OrdersListView({
    required this.orders,
    required this.onCancel,
  });

  final List<Order> orders;
  final ValueChanged<String> onCancel;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () {
            // TODO: Navigate to order details
          },
          onCancel: () => _showCancelDialog(context, order.id),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No, Keep It'),
          ),
          FilledButton(
            onPressed: () {
              onCancel(orderId);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
