import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/core/widgets/snackbar_helper.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/presentation/providers/address_provider.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/injection_container.dart';

@RoutePage()
class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GetCurrentUser _getCurrentUser = sl<GetCurrentUser>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();

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

  Future<void> _saveAddress(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (failure) {
        if (mounted) {
          showErrorSnackBar(context, message: failure.message);
        }
      },
      (user) {
        if (user != null && mounted) {
          final address = Address(
            id: const Uuid().v4(),
            userId: user.id,
            name: _nameController.text.trim(),
            street: _streetController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            zipCode: _zipCodeController.text.trim(),
            country: _countryController.text.trim(),
          );

          ref.read(addressProvider.notifier).addAddress(address);
          context.router.maybePop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Add Address'),
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
