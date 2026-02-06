import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/presentation/providers/address_provider.dart';

@RoutePage()
class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key, required this.address});

  final Address address;

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _streetController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address.name);
    _streetController = TextEditingController(text: widget.address.street);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
    _zipCodeController = TextEditingController(text: widget.address.zipCode);
    _countryController = TextEditingController(text: widget.address.country);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveAddress(WidgetRef ref) {
    if (!_formKey.currentState!.validate()) return;

    final updatedAddress = Address(
      id: widget.address.id,
      userId: widget.address.userId,
      name: _nameController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      country: _countryController.text.trim(),
    );

    ref.read(addressProvider.notifier).updateAddress(updatedAddress);
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit Address'),
          actions: [
            TextButton(
              onPressed: () => _saveAddress(ref),
              child: const Text('Save'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Address Name (e.g., Home, Work)',
                  hintText: 'Home',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an address name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  hintText: '123 Main St',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'New York',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State/Province',
                        hintText: 'NY',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a state';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _zipCodeController,
                      decoration: const InputDecoration(
                        labelText: 'ZIP/Postal Code',
                        hintText: '10001',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a ZIP code';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  hintText: 'United States',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a country';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
