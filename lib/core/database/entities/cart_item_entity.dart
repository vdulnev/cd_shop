import 'package:floor/floor.dart';

/// Database entity for cart items
///
/// Stores only the product ID and quantity. Product details are fetched
/// from the product datasource when loading the cart.
@Entity(tableName: 'cart_items')
class CartItemEntity {
  CartItemEntity({
    required this.productId,
    required this.quantity,
  });

  @primaryKey
  final String productId;

  final int quantity;
}
