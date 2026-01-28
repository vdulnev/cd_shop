import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

class UpdateAddress {
  UpdateAddress(this.repository);

  final AddressRepository repository;

  Future<Address> call(Address address) {
    return repository.updateAddress(address);
  }
}
