import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:cd_shop/core/database/daos/address_dao.dart';
import 'package:cd_shop/core/database/daos/app_settings_dao.dart';
import 'package:cd_shop/core/database/daos/cart_dao.dart';
import 'package:cd_shop/core/database/daos/order_dao.dart';
import 'package:cd_shop/core/database/daos/product_dao.dart';
import 'package:cd_shop/core/database/daos/user_dao.dart';
import 'package:cd_shop/core/database/entities/address_entity.dart';
import 'package:cd_shop/core/database/entities/app_settings_entity.dart';
import 'package:cd_shop/core/database/entities/cart_item_entity.dart';
import 'package:cd_shop/core/database/entities/order_entity.dart';
import 'package:cd_shop/core/database/entities/product_entity.dart';
import 'package:cd_shop/core/database/entities/user_entity.dart';

part 'app_database.g.dart';

@Database(
  version: 8,
  entities: [
    CartItemEntity,
    ProductEntity,
    UserEntity,
    SessionEntity,
    AddressEntity,
    OrderEntity,
    OrderItemEntity,
    AppSettingsEntity,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  CartDao get cartDao;
  ProductDao get productDao;
  UserDao get userDao;
  AddressDao get addressDao;
  OrderDao get orderDao;
  AppSettingsDao get appSettingsDao;

  static Future<AppDatabase> create() async {
    return $FloorAppDatabase
      .databaseBuilder('cd_shop.db')
      .addMigrations([
        _migration1to2,
        _migration2to3,
        _migration3to4,
        _migration4to5,
        _migration5to6,
        _migration6to7,
        _migration7to8,
      ])
      .build();
  }
}

/// Migration from version 1 to 2: Add products table
final _migration1to2 = Migration(1, 2, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY NOT NULL,
      title TEXT NOT NULL,
      artist TEXT NOT NULL,
      description TEXT NOT NULL,
      price REAL NOT NULL,
      imageUrl TEXT,
      genre TEXT NOT NULL,
      releaseYear INTEGER,
      stockQuantity INTEGER NOT NULL,
      isAvailable INTEGER NOT NULL
    )
  ''');
});

/// Migration from version 2 to 3: Add users and session tables
final _migration2to3 = Migration(2, 3, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY NOT NULL,
      email TEXT NOT NULL,
      name TEXT NOT NULL,
      avatarUrl TEXT,
      passwordHash TEXT NOT NULL
    )
  ''');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS current_session (
      id INTEGER PRIMARY KEY NOT NULL,
      userId TEXT NOT NULL
    )
  ''');

  // Create index for email lookups
  await database.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users (email)
  ''');
});

/// Migration from version 3 to 4: Add addresses table
final _migration3to4 = Migration(3, 4, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS addresses (
      id TEXT PRIMARY KEY NOT NULL,
      user_id TEXT NOT NULL,
      name TEXT NOT NULL,
      street TEXT NOT NULL,
      city TEXT NOT NULL,
      state TEXT NOT NULL,
      zip_code TEXT NOT NULL,
      country TEXT NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0
    )
  ''');

  // Create index for user_id lookups
  await database.execute('''
    CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON addresses (user_id)
  ''');
});

/// Migration from version 4 to 5: Move default address to users table
final _migration4to5 = Migration(4, 5, (database) async {
  // Add default_address_id column to users
  await database.execute('''
    ALTER TABLE users ADD COLUMN default_address_id TEXT
  ''');

  // Migrate existing default addresses from addresses to users
  await database.execute('''
    UPDATE users SET default_address_id = (
      SELECT id FROM addresses
      WHERE addresses.user_id = users.id AND addresses.is_default = 1
      LIMIT 1
    )
  ''');
});

/// Migration from version 5 to 6: Add orders and order_items tables
final _migration5to6 = Migration(5, 6, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS orders (
      id TEXT PRIMARY KEY NOT NULL,
      userId TEXT NOT NULL,
      shippingAddressId TEXT NOT NULL,
      paymentMethod TEXT NOT NULL,
      subtotal REAL NOT NULL,
      shippingCost REAL NOT NULL,
      tax REAL NOT NULL,
      total REAL NOT NULL,
      status TEXT NOT NULL,
      orderDate INTEGER NOT NULL,
      estimatedDeliveryDate INTEGER,
      notes TEXT
    )
  ''');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      orderId TEXT NOT NULL,
      productId TEXT NOT NULL,
      productTitle TEXT NOT NULL,
      productArtist TEXT NOT NULL,
      productPrice REAL NOT NULL,
      productImageUrl TEXT,
      quantity INTEGER NOT NULL,
      FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
    )
  ''');

  // Create indexes for faster lookups
  await database.execute('''
    CREATE INDEX IF NOT EXISTS idx_orders_userId ON orders (userId)
  ''');

  await database.execute('''
    CREATE INDEX IF NOT EXISTS idx_order_items_orderId ON order_items (orderId)
  ''');
});

/// Migration from version 6 to 7: Add app_settings table
final _migration6to7 = Migration(6, 7, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS app_settings (
      key TEXT PRIMARY KEY NOT NULL,
      value TEXT NOT NULL
    )
  ''');
});

/// Migration from version 7 to 8: Connect cart items to users
final _migration7to8 = Migration(7, 8, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS cart_items_new (
      user_id TEXT NOT NULL,
      productId TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      PRIMARY KEY (user_id, productId)
    )
  ''');

  await database.execute('''
    INSERT INTO cart_items_new (user_id, productId, quantity)
    SELECT COALESCE((SELECT userId FROM current_session LIMIT 1), ''),
           productId,
           quantity
    FROM cart_items
  ''');

  await database.execute('DROP TABLE cart_items');
  await database.execute('ALTER TABLE cart_items_new RENAME TO cart_items');
  await database.execute(
    'CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items (user_id)'
  );
});
