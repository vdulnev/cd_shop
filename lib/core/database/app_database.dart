import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:cd_shop/core/database/daos/cart_dao.dart';
import 'package:cd_shop/core/database/daos/product_dao.dart';
import 'package:cd_shop/core/database/daos/user_dao.dart';
import 'package:cd_shop/core/database/entities/cart_item_entity.dart';
import 'package:cd_shop/core/database/entities/product_entity.dart';
import 'package:cd_shop/core/database/entities/user_entity.dart';

part 'app_database.g.dart';

@Database(
  version: 3,
  entities: [CartItemEntity, ProductEntity, UserEntity, SessionEntity],
)
abstract class AppDatabase extends FloorDatabase {
  CartDao get cartDao;
  ProductDao get productDao;
  UserDao get userDao;

  static Future<AppDatabase> create() async {
    return $FloorAppDatabase
        .databaseBuilder('cd_shop.db')
        .addMigrations([_migration1to2, _migration2to3])
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
