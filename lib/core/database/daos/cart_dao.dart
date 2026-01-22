import 'package:floor/floor.dart';

import 'package:cd_shop/core/database/entities/cart_item_entity.dart';

@dao
abstract class CartDao {
  @Query('SELECT * FROM cart_items')
  Future<List<CartItemEntity>> getAllCartItems();

  @Query('SELECT * FROM cart_items')
  Stream<List<CartItemEntity>> watchAllCartItems();

  @Query('SELECT * FROM cart_items WHERE productId = :productId')
  Future<CartItemEntity?> getCartItem(String productId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertCartItem(CartItemEntity item);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateCartItem(CartItemEntity item);

  @Query('DELETE FROM cart_items WHERE productId = :productId')
  Future<void> deleteCartItem(String productId);

  @Query('DELETE FROM cart_items')
  Future<void> clearCart();
}
