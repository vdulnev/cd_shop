import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:dartz/dartz.dart';

class AddAddress extends UseCase<Address, Address> {
  AddAddress(this.repository);

  final AddressRepository repository;

  @override
  Future<Either<Failure, Address>> call(Address address) {
    return repository.addAddress(address);
  }
}
