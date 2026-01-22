import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:cd_shop/core/database/daos/cart_dao.dart';
import 'package:cd_shop/core/database/daos/product_dao.dart';
import 'package:cd_shop/core/database/entities/cart_item_entity.dart';
import 'package:cd_shop/core/database/entities/product_entity.dart';

part 'app_database.g.dart';

@Database(version: 2, entities: [CartItemEntity, ProductEntity])
abstract class AppDatabase extends FloorDatabase {
  CartDao get cartDao;
  ProductDao get productDao;

  static Future<AppDatabase> create() async {
    return $FloorAppDatabase
        .databaseBuilder('cd_shop.db')
        .addMigrations([_migration1to2])
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
