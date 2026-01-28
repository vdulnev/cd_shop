import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier({
    required GetCurrentUser getCurrentUser,
    required WatchAddresses watchAddresses,
    required AddAddress addAddress,
    required UpdateAddress updateAddress,
    required DeleteAddress deleteAddress,
    required SetDefaultAddress setDefaultAddress,
  })  : _getCurrentUser = getCurrentUser,
        _watchAddresses = watchAddresses,
        _addAddress = addAddress,
        _updateAddress = updateAddress,
        _deleteAddress = deleteAddress,
        _setDefaultAddress = setDefaultAddress,
        super(const AddressInitial()) {
    _loadAddresses();
  }

  final GetCurrentUser _getCurrentUser;
  final WatchAddresses _watchAddresses;
  final AddAddress _addAddress;
  final UpdateAddress _updateAddress;
  final DeleteAddress _deleteAddress;
  final SetDefaultAddress _setDefaultAddress;
  StreamSubscription<List<Address>>? _addressesSubscription;
  String? _defaultAddressId;

  Future<void> _loadAddresses() async {
    state = const AddressLoading();

    final userResult = await _getCurrentUser(const NoParams());
    final user = userResult.fold(
      (failure) => null,
      (user) => user,
    );

    if (user == null) {
      state = const AddressNotAuthenticated();
      return;
    }

    _defaultAddressId = user.defaultAddressId;
    await _addressesSubscription?.cancel();
    _addressesSubscription = _watchAddresses(user.id).listen(
      (addresses) {
        state = AddressesLoadedState(
          addresses: addresses,
          defaultAddressId: _defaultAddressId,
        );
      },
    );
  }

  Future<void> addAddress(Address address) async {
    await _addAddress(address);
  }

  Future<void> updateAddress(Address address) async {
    await _updateAddress(address);
  }

  Future<void> deleteAddress(String addressId) async {
    await _deleteAddress(addressId);
  }

  Future<void> setDefaultAddress(String addressId) async {
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

  @override
  void dispose() {
    _addressesSubscription?.cancel();
    super.dispose();
  }
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier(
    getCurrentUser: sl<GetCurrentUser>(),
    watchAddresses: sl<WatchAddresses>(),
    addAddress: sl<AddAddress>(),
    updateAddress: sl<UpdateAddress>(),
    deleteAddress: sl<DeleteAddress>(),
    setDefaultAddress: sl<SetDefaultAddress>(),
  );
});
