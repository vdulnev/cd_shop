import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

class WatchAddresses extends StreamUseCase<List<Address>, String> {
  WatchAddresses(this.repository);

  final AddressRepository repository;

  @override
  Stream<List<Address>> call(String userId) {
    return repository.watchAddresses(userId);
  }
}
