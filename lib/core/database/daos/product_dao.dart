import 'package:floor/floor.dart';

import 'package:cd_shop/core/database/entities/product_entity.dart';

@dao
abstract class ProductDao {
  @Query('SELECT * FROM products')
  Future<List<ProductEntity>> getAllProducts();

  @Query('SELECT * FROM products')
  Stream<List<ProductEntity>> watchAllProducts();

  @Query('SELECT * FROM products WHERE id = :id')
  Future<ProductEntity?> getProductById(String id);

  @Query('SELECT * FROM products WHERE genre = :genre')
  Future<List<ProductEntity>> getProductsByGenre(String genre);

  @Query('''
    SELECT * FROM products
    WHERE title LIKE :query
    OR artist LIKE :query
    OR description LIKE :query
  ''')
  Future<List<ProductEntity>> searchProducts(String query);

  @Query('SELECT * FROM products LIMIT :limit')
  Future<List<ProductEntity>> getFeaturedProducts(int limit);

  @Query('SELECT COUNT(*) FROM products')
  Future<int?> getProductCount();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertProduct(ProductEntity product);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertProducts(List<ProductEntity> products);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateProduct(ProductEntity product);

  @Query('DELETE FROM products WHERE id = :id')
  Future<void> deleteProduct(String id);

  @Query('DELETE FROM products')
  Future<void> clearProducts();
}
