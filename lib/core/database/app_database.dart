import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:cd_shop/core/database/daos/address_dao.dart';
import 'package:cd_shop/core/database/daos/cart_dao.dart';
import 'package:cd_shop/core/database/daos/order_dao.dart';
import 'package:cd_shop/core/database/daos/product_dao.dart';
import 'package:cd_shop/core/database/daos/user_dao.dart';
import 'package:cd_shop/core/database/entities/address_entity.dart';
import 'package:cd_shop/core/database/entities/cart_item_entity.dart';
import 'package:cd_shop/core/database/entities/order_entity.dart';
import 'package:cd_shop/core/database/entities/product_entity.dart';
import 'package:cd_shop/core/database/entities/user_entity.dart';

part 'app_database.g.dart';

@Database(
  version: 6,
  entities: [CartItemEntity, ProductEntity, UserEntity, SessionEntity, AddressEntity, OrderEntity, OrderItemEntity],
)
abstract class AppDatabase extends FloorDatabase {
  CartDao get cartDao;
  ProductDao get productDao;
  UserDao get userDao;
  AddressDao get addressDao;
  OrderDao get orderDao;

  static Future<AppDatabase> create() async {
    return $FloorAppDatabase
      .databaseBuilder('cd_shop.db')
      .addMigrations([_migration1to2, _migration2to3, _migration3to4, _migration4to5, _migration5to6])
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
