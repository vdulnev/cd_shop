import 'package:equatable/equatable.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';

sealed class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressesLoadedState extends AddressState {
  const AddressesLoadedState({
    required this.addresses,
    this.defaultAddressId,
  });

  final List<Address> addresses;
  final String? defaultAddressId;

  @override
  List<Object?> get props => [addresses, defaultAddressId];
}

class AddressError extends AddressState {
  const AddressError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AddressNotAuthenticated extends AddressState {
  const AddressNotAuthenticated();
}
