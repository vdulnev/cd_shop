import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

/// Use case to delete an address
abstract interface class DeleteAddress {
  Future<void> call(String addressId);
}

@LazySingleton(as: DeleteAddress)
class DeleteAddressImpl implements DeleteAddress {
  DeleteAddressImpl(this.repository);

  final AddressRepository repository;

  @override
  Future<void> call(String addressId) {
    return repository.deleteAddress(addressId);
  }
}
