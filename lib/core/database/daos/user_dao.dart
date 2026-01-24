import 'package:floor/floor.dart';

import 'package:cd_shop/core/database/entities/user_entity.dart';

@dao
abstract class UserDao {
  // User operations
  @Query('SELECT * FROM users WHERE email = :email')
  Future<UserEntity?> getUserByEmail(String email);

  @Query('SELECT * FROM users WHERE id = :id')
  Future<UserEntity?> getUserById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUser(UserEntity user);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateUser(UserEntity user);

  @Query('DELETE FROM users WHERE id = :id')
  Future<void> deleteUser(String id);

  @Query('UPDATE users SET default_address_id = :addressId WHERE id = :userId')
  Future<void> setDefaultAddress(String userId, String addressId);

  @Query('UPDATE users SET default_address_id = NULL WHERE id = :userId')
  Future<void> clearDefaultAddress(String userId);

  // Session operations
  @Query('SELECT * FROM current_session WHERE id = 1')
  Future<SessionEntity?> getCurrentSession();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> setCurrentSession(SessionEntity session);

  @Query('DELETE FROM current_session')
  Future<void> clearSession();
}
