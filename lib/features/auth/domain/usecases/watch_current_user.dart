import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

abstract interface class WatchCurrentUser {
  Stream<User?> call();
}

/// Use case to watch current signed-in user changes
@LazySingleton(as: WatchCurrentUser)
class WatchCurrentUserImpl implements WatchCurrentUser {
  WatchCurrentUserImpl(this._repository);

  final AuthRepository _repository;

  @override
  Stream<User?> call() => _repository.watchCurrentUser();
}
