import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';

import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/usecases/add_address.dart';
import 'package:cd_shop/features/address/domain/usecases/delete_address.dart';
import 'package:cd_shop/features/address/domain/usecases/update_address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/address/presentation/providers/address_state.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/set_default_address.dart';
import 'package:cd_shop/injection_container.dart';

class AddressNotifier extends Notifier<AddressState> {
  late final GetCurrentUser _getCurrentUser;
  late final WatchAddresses _watchAddresses;
  late final AddAddress _addAddress;
  late final UpdateAddress _updateAddress;
  late final DeleteAddress _deleteAddress;
  late final SetDefaultAddress _setDefaultAddress;
  StreamSubscription<List<Address>>? _addressesSubscription;
  String? _defaultAddressId;
  Talker get _log => sl<Talker>();

  @override
  AddressState build() {
    _getCurrentUser = sl<GetCurrentUser>();
    _watchAddresses = sl<WatchAddresses>();
    _addAddress = sl<AddAddress>();
    _updateAddress = sl<UpdateAddress>();
    _deleteAddress = sl<DeleteAddress>();
    _setDefaultAddress = sl<SetDefaultAddress>();

    ref.onDispose(() {
      _addressesSubscription?.cancel();
    });

    _loadAddresses();
    return const AddressInitial();
  }

  Future<void> _loadAddresses() async {
    _log.info('Loading addresses...');
    state = const AddressLoading();

    final userResult = await _getCurrentUser(const NoParams());
    final user = userResult.fold(
      (failure) => null,
      (user) => user,
    );

    if (user == null) {
      _log.warning('User not authenticated, cannot load addresses');
      state = const AddressNotAuthenticated();
      return;
    }

    _defaultAddressId = user.defaultAddressId;
    await _addressesSubscription?.cancel();
    _log.info('Subscribing to addresses for user ${user.id}');
    _addressesSubscription = _watchAddresses(user.id).listen(
      (addresses) {
        _log.info('Addresses updated: ${addresses.length} addresses');
        state = AddressesLoadedState(
          addresses: addresses,
          defaultAddressId: _defaultAddressId,
        );
      },
    );
  }

  Future<void> addAddress(Address address) async {
    _log.info('Adding address "${address.name}"');
    await _addAddress(address);
  }

  Future<void> updateAddress(Address address) async {
    _log.info('Updating address ${address.id}');
    await _updateAddress(address);
  }

  Future<void> deleteAddress(String addressId) async {
    _log.info('Deleting address $addressId');
    await _deleteAddress(addressId);
  }

  Future<void> setDefaultAddress(String addressId) async {
    _log.info('Setting default address to $addressId');
    final result = await _setDefaultAddress(addressId);
    result.fold(
      (_) {},
      (_) {
        _defaultAddressId = addressId;
        final currentState = state;
        if (currentState is AddressesLoadedState) {
          state = AddressesLoadedState(
            addresses: currentState.addresses,
            defaultAddressId: addressId,
          );
        }
      },
    );
  }
}

final addressProvider =
    NotifierProvider<AddressNotifier, AddressState>(AddressNotifier.new);
