import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

/// Use case to set the default address
abstract interface class SetDefaultAddress implements UseCase<void, String> {}

@LazySingleton(as: SetDefaultAddress)
class SetDefaultAddressImpl implements SetDefaultAddress {
  SetDefaultAddressImpl(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(String? addressId) {
    return repository.setDefaultAddress(addressId);
  }
}
