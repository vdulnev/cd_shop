import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/presentation/providers/address_state.dart';
import 'package:cd_shop/features/address/presentation/providers/address_provider.dart';

class AddressesPage extends ConsumerWidget {
  const AddressesPage({super.key});

  void _openAddAddress(BuildContext context) {
    context.push('/account/addresses/add');
  }

  void _openEditAddress(BuildContext context, Address address) {
    context.push('/account/addresses/${address.id}/edit', extra: address);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        actions: [
          IconButton(
            onPressed: () => _openAddAddress(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: switch (state) {
        AddressInitial() || AddressLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
        AddressesLoadedState(:final addresses, :final defaultAddressId) =>
          addresses.isEmpty
              ? _EmptyState(onAddPressed: () => _openAddAddress(context))
              : _AddressesList(
                  addresses: addresses,
                  defaultAddressId: defaultAddressId,
                  onSetDefault: (id) =>
                      ref.read(addressProvider.notifier).setDefaultAddress(id),
                  onEdit: (address) => _openEditAddress(context, address),
                  onDelete: (id) =>
                      ref.read(addressProvider.notifier).deleteAddress(id),
                ),
        AddressNotAuthenticated() => const Center(
            child: Text('Please log in to view addresses'),
          ),
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No addresses yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onAddPressed,
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }
}

class _AddressesList extends StatelessWidget {
  const _AddressesList({
    required this.addresses,
    required this.defaultAddressId,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Address> addresses;
  final String? defaultAddressId;
  final void Function(String) onSetDefault;
  final void Function(Address) onEdit;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final address = addresses[index];
        final isDefault = address.id == defaultAddressId;
        return _AddressCard(
          address: address,
          isDefault: isDefault,
          onSetDefault: onSetDefault,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isDefault,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final Address address;
  final bool isDefault;
  final void Function(String) onSetDefault;
  final void Function(Address) onEdit;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  address.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (isDefault) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('Default'),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ],
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit(address);
                        break;
                      case 'delete':
                        _showDeleteDialog(context, address);
                        break;
                      case 'set_default':
                        onSetDefault(address.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    if (!isDefault)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: Text('Set as Default'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(address.street),
            Text('${address.city}, ${address.state} ${address.zipCode}'),
            Text(address.country),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete "${address.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete(address.id);
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
