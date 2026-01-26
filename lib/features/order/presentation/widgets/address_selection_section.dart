import 'package:flutter/material.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';

class AddressSelectionSection extends StatelessWidget {
  const AddressSelectionSection({
    super.key,
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
  });

  final List<Address> addresses;
  final Address? selectedAddress;
  final ValueChanged<Address?> onAddressSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (addresses.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.location_off, size: 48),
                    const SizedBox(height: 8),
                    const Text('No addresses found'),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to add address
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Address'),
                    ),
                  ],
                ),
              ),
            )
          else
            RadioGroup<String>(
              groupValue: selectedAddress?.id,
              onChanged: (value) {
                final selected = addresses.firstWhere(
                  (a) => a.id == value,
                  orElse: () => addresses.first,
                );
                onAddressSelected(selected);
              },
              child: Column(
                children: addresses
                    .map((address) => _buildAddressCard(
                          context,
                          address,
                          isSelected: address.id == selectedAddress?.id,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    Address address, {
    required bool isSelected,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => onAddressSelected(address),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<String>(
                value: address.id,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(address.street),
                    Text('${address.city}, ${address.state} ${address.zipCode}'),
                    Text(address.country),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
