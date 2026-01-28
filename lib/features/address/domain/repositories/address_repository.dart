import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';

abstract class AddressRepository {
  Stream<List<Address>> watchAddresses(String userId);
  Stream<RepositoryEvent> eventStream();
  Future<Address> addAddress(Address address);
  Future<Address> updateAddress(Address address);
  Future<void> deleteAddress(String addressId);
}
