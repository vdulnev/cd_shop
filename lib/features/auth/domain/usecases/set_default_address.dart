import 'package:dartz/dartz.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/core/usecases/usecase.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

class SetDefaultAddress extends UseCase<void, String?> {
  SetDefaultAddress(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(String? addressId) {
    return repository.setDefaultAddress(addressId);
  }
}
