import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

@lazySingleton
class WatchAddresses {
  WatchAddresses(this.repository);

  final AddressRepository repository;

  Stream<List<Address>> call(String userId) {
    return repository.watchAddresses(userId);
  }
}
