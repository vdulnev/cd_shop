import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

/// Use case to watch list of addresses
abstract interface class WatchAddresses {
  Stream<List<Address>> call(String userId);
}

@LazySingleton(as: WatchAddresses)
class WatchAddressesImpl implements WatchAddresses {
  WatchAddressesImpl(this.repository);

  final AddressRepository repository;

  @override
  Stream<List<Address>> call(String userId) =>
      repository.watchAddresses(userId);
}
