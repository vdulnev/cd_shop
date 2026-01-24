import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:dartz/dartz.dart';

abstract class AddressRepository {
  Stream<List<Address>> watchAddresses(String userId);
  Stream<RepositoryEvent> eventStream();
  Future<Either<Failure, Address>> addAddress(Address address);
  Future<Either<Failure, Address>> updateAddress(Address address);
  Future<Either<Failure, void>> deleteAddress(String addressId);
}
