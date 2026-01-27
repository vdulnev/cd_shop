import 'package:equatable/equatable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';

sealed class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class AddressesLoaded extends AddressEvent {
  const AddressesLoaded();
}

class AddressesStreamUpdated extends AddressEvent {
  const AddressesStreamUpdated(this.addresses);

  final List<Address> addresses;

  @override
  List<Object?> get props => [addresses];
}

class AddressesStreamFailed extends AddressEvent {
  const AddressesStreamFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class AddressAdded extends AddressEvent {
  const AddressAdded(this.address);

  final Address address;

  @override
  List<Object?> get props => [address];
}

class AddressUpdated extends AddressEvent {
  const AddressUpdated(this.address);

  final Address address;

  @override
  List<Object?> get props => [address];
}

class AddressDeleted extends AddressEvent {
  const AddressDeleted(this.addressId);

  final String addressId;

  @override
  List<Object?> get props => [addressId];
}

class DefaultAddressSet extends AddressEvent {
  const DefaultAddressSet(this.addressId);

  final String addressId;

  @override
  List<Object?> get props => [addressId];
}
