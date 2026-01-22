// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CartDao? _cartDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `cart_items` (`productId` TEXT NOT NULL, `quantity` INTEGER NOT NULL, PRIMARY KEY (`productId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CartDao get cartDao {
    return _cartDaoInstance ??= _$CartDao(database, changeListener);
  }
}

class _$CartDao extends CartDao {
  _$CartDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _cartItemEntityInsertionAdapter = InsertionAdapter(
            database,
            'cart_items',
            (CartItemEntity item) => <String, Object?>{
                  'productId': item.productId,
                  'quantity': item.quantity
                },
            changeListener),
        _cartItemEntityUpdateAdapter = UpdateAdapter(
            database,
            'cart_items',
            ['productId'],
            (CartItemEntity item) => <String, Object?>{
                  'productId': item.productId,
                  'quantity': item.quantity
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CartItemEntity> _cartItemEntityInsertionAdapter;

  final UpdateAdapter<CartItemEntity> _cartItemEntityUpdateAdapter;

  @override
  Future<List<CartItemEntity>> getAllCartItems() async {
    return _queryAdapter.queryList('SELECT * FROM cart_items',
        mapper: (Map<String, Object?> row) => CartItemEntity(
            productId: row['productId'] as String,
            quantity: row['quantity'] as int));
  }

  @override
  Stream<List<CartItemEntity>> watchAllCartItems() {
    return _queryAdapter.queryListStream('SELECT * FROM cart_items',
        mapper: (Map<String, Object?> row) => CartItemEntity(
            productId: row['productId'] as String,
            quantity: row['quantity'] as int),
        queryableName: 'cart_items',
        isView: false);
  }

  @override
  Future<CartItemEntity?> getCartItem(String productId) async {
    return _queryAdapter.query('SELECT * FROM cart_items WHERE productId = ?1',
        mapper: (Map<String, Object?> row) => CartItemEntity(
            productId: row['productId'] as String,
            quantity: row['quantity'] as int),
        arguments: [productId]);
  }

  @override
  Future<void> deleteCartItem(String productId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM cart_items WHERE productId = ?1',
        arguments: [productId]);
  }

  @override
  Future<void> clearCart() async {
    await _queryAdapter.queryNoReturn('DELETE FROM cart_items');
  }

  @override
  Future<void> insertCartItem(CartItemEntity item) async {
    await _cartItemEntityInsertionAdapter.insert(
        item, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateCartItem(CartItemEntity item) async {
    await _cartItemEntityUpdateAdapter.update(item, OnConflictStrategy.replace);
  }
}
