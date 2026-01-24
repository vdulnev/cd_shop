import 'package:floor/floor.dart';

import 'package:cd_shop/core/database/entities/address_entity.dart';

@dao
abstract class AddressDao {
  @Query('SELECT * FROM addresses WHERE user_id = :userId')
  Future<List<AddressEntity>> getAddressesByUserId(String userId);

  @Query('SELECT * FROM addresses WHERE user_id = :userId')
  Stream<List<AddressEntity>> watchAddressesByUserId(String userId);

  @Query('SELECT * FROM addresses WHERE id = :id')
  Future<AddressEntity?> getAddressById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAddress(AddressEntity address);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateAddress(AddressEntity address);

  @Query('DELETE FROM addresses WHERE id = :id')
  Future<void> deleteAddress(String id);
}
