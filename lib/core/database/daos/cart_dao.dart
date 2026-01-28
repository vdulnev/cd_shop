import 'package:floor/floor.dart';

import 'package:cd_shop/core/database/entities/cart_item_entity.dart';

@dao
abstract class CartDao {
  @Query('SELECT * FROM cart_items WHERE user_id = :userId')
  Future<List<CartItemEntity>> getAllCartItems(String userId);

  @Query('SELECT * FROM cart_items WHERE user_id = :userId')
  Stream<List<CartItemEntity>> watchCartItems(String userId);

  @Query(
    'SELECT * FROM cart_items WHERE user_id = :userId AND productId = :productId',
  )
  Future<CartItemEntity?> getCartItem(String userId, String productId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertCartItem(CartItemEntity item);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateCartItem(CartItemEntity item);

  @Query(
    'DELETE FROM cart_items WHERE user_id = :userId AND productId = :productId',
  )
  Future<void> deleteCartItem(String userId, String productId);

  @Query('DELETE FROM cart_items WHERE user_id = :userId')
  Future<void> clearCart(String userId);
}
