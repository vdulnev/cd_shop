import 'package:injectable/injectable.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

/// Use case to add a new address
abstract interface class AddAddress {
  Future<Address> call(Address address);
}

@LazySingleton(as: AddAddress)
class AddAddressImpl implements AddAddress {
  AddAddressImpl(this.repository);

  final AddressRepository repository;

  @override
  Future<Address> call(Address address) {
    return repository.addAddress(address);
  }
}
