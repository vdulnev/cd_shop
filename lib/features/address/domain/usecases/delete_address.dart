import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteAddress extends UseCase<void, String> {
  DeleteAddress(this.repository);

  final AddressRepository repository;

  @override
  Future<Either<Failure, void>> call(String addressId) {
    return repository.deleteAddress(addressId);
  }
}
