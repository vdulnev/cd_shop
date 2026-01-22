import 'package:floor/floor.dart';

import 'package:cd_shop/features/auth/domain/entities/user.dart';

/// Database entity for registered users
@Entity(tableName: 'users')
class UserEntity {
  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.passwordHash,
  });

  /// Convert from domain entity to database entity
  factory UserEntity.fromDomain(User user, String passwordHash) {
    return UserEntity(
      id: user.id,
      email: user.email,
      name: user.name,
      avatarUrl: user.avatarUrl,
      passwordHash: passwordHash,
    );
  }

  @primaryKey
  final String id;

  final String email;
  final String name;
  final String? avatarUrl;
  final String passwordHash;

  /// Convert to domain entity
  User toDomain() {
    return User(
      id: id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
    );
  }
}

/// Database entity for current session (logged in user)
@Entity(tableName: 'current_session')
class SessionEntity {
  SessionEntity({required this.id, required this.userId});

  @primaryKey
  final int id; // Always 1, single row table

  final String userId;
}
