import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

/// Use case to update an existing address
abstract interface class UpdateAddress {
  Future<Address> call(Address address);
}

@LazySingleton(as: UpdateAddress)
class UpdateAddressImpl implements UpdateAddress {
  UpdateAddressImpl(this.repository);

  final AddressRepository repository;

  @override
  Future<Address> call(Address address) {
    return repository.updateAddress(address);
  }
}
