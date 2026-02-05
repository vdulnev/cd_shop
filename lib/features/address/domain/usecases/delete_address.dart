import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

@lazySingleton
class DeleteAddress {
  DeleteAddress(this.repository);

  final AddressRepository repository;

  Future<void> call(String addressId) {
    return repository.deleteAddress(addressId);
  }
}
