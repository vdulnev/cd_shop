import 'package:floor/floor.dart';

/// Database entity for cart items
///
/// Stores the user ID, product ID, and quantity. Product details are fetched
/// from the product datasource when loading the cart.
@Entity(tableName: 'cart_items', primaryKeys: ['userId', 'productId'])
class CartItemEntity {
  CartItemEntity({
    required this.userId,
    required this.productId,
    required this.quantity,
  });

  @ColumnInfo(name: 'user_id')
  final String userId;

  final String productId;

  final int quantity;
}
