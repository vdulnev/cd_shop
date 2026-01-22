import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:cd_shop/core/database/daos/cart_dao.dart';
import 'package:cd_shop/core/database/entities/cart_item_entity.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [CartItemEntity])
abstract class AppDatabase extends FloorDatabase {
  CartDao get cartDao;

  static Future<AppDatabase> create() async {
    return $FloorAppDatabase.databaseBuilder('cd_shop.db').build();
  }
}
