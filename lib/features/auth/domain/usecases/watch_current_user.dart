import 'package:injectable/injectable.dart';
import 'package:cd_shop/features/auth/domain/entities/user.dart';
import 'package:cd_shop/features/auth/domain/repositories/auth_repository.dart';

/// Use case to watch current signed-in user changes
@lazySingleton
class WatchCurrentUser {
  WatchCurrentUser(this._repository);

  final AuthRepository _repository;

  Stream<User?> call() => _repository.watchCurrentUser();
}
