import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/usecases/add_address.dart';
import 'package:cd_shop/features/address/domain/usecases/delete_address.dart';
import 'package:cd_shop/features/address/domain/usecases/watch_addresses.dart';
import 'package:cd_shop/features/address/domain/usecases/update_address.dart';
import 'package:cd_shop/features/auth/domain/usecases/get_current_user.dart';
import 'package:cd_shop/features/auth/domain/usecases/set_default_address.dart';

import 'address_event.dart';
import 'address_state.dart';

export 'address_event.dart';
export 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc({
    required GetCurrentUser getCurrentUser,
    required WatchAddresses getAddresses,
    required AddAddress addAddress,
    required UpdateAddress updateAddress,
    required DeleteAddress deleteAddress,
    required SetDefaultAddress setDefaultAddress,
  })  : _getCurrentUser = getCurrentUser,
        _getAddresses = getAddresses,
        _addAddress = addAddress,
        _updateAddress = updateAddress,
        _deleteAddress = deleteAddress,
        _setDefaultAddress = setDefaultAddress,
        super(const AddressInitial()) {
    on<AddressesLoaded>(_onAddressesLoaded);
    on<AddressesStreamUpdated>(_onAddressesStreamUpdated);
    on<AddressesStreamFailed>(_onAddressesStreamFailed);
    on<AddressAdded>(_onAddressAdded);
    on<AddressUpdated>(_onAddressUpdated);
    on<AddressDeleted>(_onAddressDeleted);
    on<DefaultAddressSet>(_onDefaultAddressSet);
  }

  final GetCurrentUser _getCurrentUser;
  final WatchAddresses _getAddresses;
  final AddAddress _addAddress;
  final UpdateAddress _updateAddress;
  final DeleteAddress _deleteAddress;
  final SetDefaultAddress _setDefaultAddress;
  StreamSubscription<List<Address>>? _addressesSubscription;
  String? _defaultAddressId;

  Future<void> _onAddressesLoaded(
    AddressesLoaded event,
    Emitter<AddressState> emit,
  ) async {
    emit(const AddressLoading());

    final userResult = await _getCurrentUser(const NoParams());
    final user = userResult.fold(
      (failure) => null,
      (user) => user,
    );

    if (user == null) {
      emit(const AddressNotAuthenticated());
      return;
    }

    _defaultAddressId = user.defaultAddressId;
    await _addressesSubscription?.cancel();
    _addressesSubscription = _getAddresses(user.id).listen(
      (addresses) => add(AddressesStreamUpdated(addresses)),
      onError: (error) {
        if (error is Failure) {
          add(AddressesStreamFailed(error));
        } else {
          add(const AddressesStreamFailed(CacheFailure()));
        }
      },
    );
  }

  void _onAddressesStreamUpdated(
    AddressesStreamUpdated event,
    Emitter<AddressState> emit,
  ) {
    emit(AddressesLoadedState(
      addresses: event.addresses,
      defaultAddressId: _defaultAddressId,
    ));
  }

  void _onAddressesStreamFailed(
    AddressesStreamFailed event,
    Emitter<AddressState> emit,
  ) {
    emit(AddressError(event.failure.message));
  }

  Future<void> _onAddressAdded(
    AddressAdded event,
    Emitter<AddressState> emit,
  ) async {
    final result = await _addAddress(event.address);
    result.fold(
      (failure) => emit(AddressError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onAddressUpdated(
    AddressUpdated event,
    Emitter<AddressState> emit,
  ) async {
    final result = await _updateAddress(event.address);
    result.fold(
      (failure) => emit(AddressError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onAddressDeleted(
    AddressDeleted event,
    Emitter<AddressState> emit,
  ) async {
    final result = await _deleteAddress(event.addressId);
    result.fold(
      (failure) => emit(AddressError(failure.message)),
      (_) {},
    );
  }

  Future<void> _onDefaultAddressSet(
    DefaultAddressSet event,
    Emitter<AddressState> emit,
  ) async {
    final result = await _setDefaultAddress(event.addressId);
    result.fold(
      (failure) => emit(AddressError(failure.message)),
      (_) {
        _defaultAddressId = event.addressId;
        final currentState = state;
        if (currentState is AddressesLoadedState) {
          emit(AddressesLoadedState(
            addresses: currentState.addresses,
            defaultAddressId: event.addressId,
          ));
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _addressesSubscription?.cancel();
    return super.close();
  }
}
