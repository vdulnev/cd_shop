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

  ProductDao? _productDaoInstance;

  UserDao? _userDaoInstance;

  AddressDao? _addressDaoInstance;

  OrderDao? _orderDaoInstance;

  AppSettingsDao? _appSettingsDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 7,
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
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `products` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `artist` TEXT NOT NULL, `description` TEXT NOT NULL, `price` REAL NOT NULL, `imageUrl` TEXT, `genre` TEXT NOT NULL, `releaseYear` INTEGER, `stockQuantity` INTEGER NOT NULL, `isAvailable` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`id` TEXT NOT NULL, `email` TEXT NOT NULL, `name` TEXT NOT NULL, `avatarUrl` TEXT, `passwordHash` TEXT NOT NULL, `default_address_id` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `current_session` (`id` INTEGER NOT NULL, `userId` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `addresses` (`id` TEXT NOT NULL, `user_id` TEXT NOT NULL, `name` TEXT NOT NULL, `street` TEXT NOT NULL, `city` TEXT NOT NULL, `state` TEXT NOT NULL, `zip_code` TEXT NOT NULL, `country` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `orders` (`id` TEXT NOT NULL, `userId` TEXT NOT NULL, `shippingAddressId` TEXT NOT NULL, `paymentMethod` TEXT NOT NULL, `subtotal` REAL NOT NULL, `shippingCost` REAL NOT NULL, `tax` REAL NOT NULL, `total` REAL NOT NULL, `status` TEXT NOT NULL, `orderDate` INTEGER NOT NULL, `estimatedDeliveryDate` INTEGER, `notes` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `order_items` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `orderId` TEXT NOT NULL, `productId` TEXT NOT NULL, `productTitle` TEXT NOT NULL, `productArtist` TEXT NOT NULL, `productPrice` REAL NOT NULL, `productImageUrl` TEXT, `quantity` INTEGER NOT NULL, FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `app_settings` (`key` TEXT NOT NULL, `value` TEXT NOT NULL, PRIMARY KEY (`key`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CartDao get cartDao {
    return _cartDaoInstance ??= _$CartDao(database, changeListener);
  }

  @override
  ProductDao get productDao {
    return _productDaoInstance ??= _$ProductDao(database, changeListener);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  AddressDao get addressDao {
    return _addressDaoInstance ??= _$AddressDao(database, changeListener);
  }

  @override
  OrderDao get orderDao {
    return _orderDaoInstance ??= _$OrderDao(database, changeListener);
  }

  @override
  AppSettingsDao get appSettingsDao {
    return _appSettingsDaoInstance ??=
        _$AppSettingsDao(database, changeListener);
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

class _$ProductDao extends ProductDao {
  _$ProductDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _productEntityInsertionAdapter = InsertionAdapter(
            database,
            'products',
            (ProductEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'artist': item.artist,
                  'description': item.description,
                  'price': item.price,
                  'imageUrl': item.imageUrl,
                  'genre': item.genre,
                  'releaseYear': item.releaseYear,
                  'stockQuantity': item.stockQuantity,
                  'isAvailable': item.isAvailable ? 1 : 0
                },
            changeListener),
        _productEntityUpdateAdapter = UpdateAdapter(
            database,
            'products',
            ['id'],
            (ProductEntity item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'artist': item.artist,
                  'description': item.description,
                  'price': item.price,
                  'imageUrl': item.imageUrl,
                  'genre': item.genre,
                  'releaseYear': item.releaseYear,
                  'stockQuantity': item.stockQuantity,
                  'isAvailable': item.isAvailable ? 1 : 0
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ProductEntity> _productEntityInsertionAdapter;

  final UpdateAdapter<ProductEntity> _productEntityUpdateAdapter;

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    return _queryAdapter.queryList('SELECT * FROM products',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            artist: row['artist'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            imageUrl: row['imageUrl'] as String?,
            genre: row['genre'] as String,
            releaseYear: row['releaseYear'] as int?,
            stockQuantity: row['stockQuantity'] as int,
            isAvailable: (row['isAvailable'] as int) != 0));
  }

  @override
  Stream<List<ProductEntity>> watchAllProducts() {
    return _queryAdapter.queryListStream('SELECT * FROM products',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            artist: row['artist'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            imageUrl: row['imageUrl'] as String?,
            genre: row['genre'] as String,
            releaseYear: row['releaseYear'] as int?,
            stockQuantity: row['stockQuantity'] as int,
            isAvailable: (row['isAvailable'] as int) != 0),
        queryableName: 'products',
        isView: false);
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    return _queryAdapter.query('SELECT * FROM products WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            artist: row['artist'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            imageUrl: row['imageUrl'] as String?,
            genre: row['genre'] as String,
            releaseYear: row['releaseYear'] as int?,
            stockQuantity: row['stockQuantity'] as int,
            isAvailable: (row['isAvailable'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<List<ProductEntity>> getProductsByGenre(String genre) async {
    return _queryAdapter.queryList('SELECT * FROM products WHERE genre = ?1',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            artist: row['artist'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            imageUrl: row['imageUrl'] as String?,
            genre: row['genre'] as String,
            releaseYear: row['releaseYear'] as int?,
            stockQuantity: row['stockQuantity'] as int,
            isAvailable: (row['isAvailable'] as int) != 0),
        arguments: [genre]);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    return _queryAdapter.queryList(
        'SELECT * FROM products     WHERE title LIKE ?1     OR artist LIKE ?1     OR description LIKE ?1',
        mapper: (Map<String, Object?> row) => ProductEntity(id: row['id'] as String, title: row['title'] as String, artist: row['artist'] as String, description: row['description'] as String, price: row['price'] as double, imageUrl: row['imageUrl'] as String?, genre: row['genre'] as String, releaseYear: row['releaseYear'] as int?, stockQuantity: row['stockQuantity'] as int, isAvailable: (row['isAvailable'] as int) != 0),
        arguments: [query]);
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts(int limit) async {
    return _queryAdapter.queryList('SELECT * FROM products LIMIT ?1',
        mapper: (Map<String, Object?> row) => ProductEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            artist: row['artist'] as String,
            description: row['description'] as String,
            price: row['price'] as double,
            imageUrl: row['imageUrl'] as String?,
            genre: row['genre'] as String,
            releaseYear: row['releaseYear'] as int?,
            stockQuantity: row['stockQuantity'] as int,
            isAvailable: (row['isAvailable'] as int) != 0),
        arguments: [limit]);
  }

  @override
  Future<int?> getProductCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM products',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM products WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> clearProducts() async {
    await _queryAdapter.queryNoReturn('DELETE FROM products');
  }

  @override
  Future<void> insertProduct(ProductEntity product) async {
    await _productEntityInsertionAdapter.insert(
        product, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertProducts(List<ProductEntity> products) async {
    await _productEntityInsertionAdapter.insertList(
        products, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    await _productEntityUpdateAdapter.update(
        product, OnConflictStrategy.replace);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userEntityInsertionAdapter = InsertionAdapter(
            database,
            'users',
            (UserEntity item) => <String, Object?>{
                  'id': item.id,
                  'email': item.email,
                  'name': item.name,
                  'avatarUrl': item.avatarUrl,
                  'passwordHash': item.passwordHash,
                  'default_address_id': item.defaultAddressId
                }),
        _sessionEntityInsertionAdapter = InsertionAdapter(
            database,
            'current_session',
            (SessionEntity item) =>
                <String, Object?>{'id': item.id, 'userId': item.userId}),
        _userEntityUpdateAdapter = UpdateAdapter(
            database,
            'users',
            ['id'],
            (UserEntity item) => <String, Object?>{
                  'id': item.id,
                  'email': item.email,
                  'name': item.name,
                  'avatarUrl': item.avatarUrl,
                  'passwordHash': item.passwordHash,
                  'default_address_id': item.defaultAddressId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserEntity> _userEntityInsertionAdapter;

  final InsertionAdapter<SessionEntity> _sessionEntityInsertionAdapter;

  final UpdateAdapter<UserEntity> _userEntityUpdateAdapter;

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    return _queryAdapter.query('SELECT * FROM users WHERE email = ?1',
        mapper: (Map<String, Object?> row) => UserEntity(
            id: row['id'] as String,
            email: row['email'] as String,
            name: row['name'] as String,
            avatarUrl: row['avatarUrl'] as String?,
            passwordHash: row['passwordHash'] as String,
            defaultAddressId: row['default_address_id'] as String?),
        arguments: [email]);
  }

  @override
  Future<UserEntity?> getUserById(String id) async {
    return _queryAdapter.query('SELECT * FROM users WHERE id = ?1',
        mapper: (Map<String, Object?> row) => UserEntity(
            id: row['id'] as String,
            email: row['email'] as String,
            name: row['name'] as String,
            avatarUrl: row['avatarUrl'] as String?,
            passwordHash: row['passwordHash'] as String,
            defaultAddressId: row['default_address_id'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM users WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> setDefaultAddress(
    String userId,
    String addressId,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE users SET default_address_id = ?2 WHERE id = ?1',
        arguments: [userId, addressId]);
  }

  @override
  Future<void> clearDefaultAddress(String userId) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE users SET default_address_id = NULL WHERE id = ?1',
        arguments: [userId]);
  }

  @override
  Future<SessionEntity?> getCurrentSession() async {
    return _queryAdapter.query('SELECT * FROM current_session WHERE id = 1',
        mapper: (Map<String, Object?> row) => SessionEntity(
            id: row['id'] as int, userId: row['userId'] as String));
  }

  @override
  Future<void> clearSession() async {
    await _queryAdapter.queryNoReturn('DELETE FROM current_session');
  }

  @override
  Future<void> insertUser(UserEntity user) async {
    await _userEntityInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }

  @override
  Future<void> setCurrentSession(SessionEntity session) async {
    await _sessionEntityInsertionAdapter.insert(
        session, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _userEntityUpdateAdapter.update(user, OnConflictStrategy.replace);
  }
}

class _$AddressDao extends AddressDao {
  _$AddressDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _addressEntityInsertionAdapter = InsertionAdapter(
            database,
            'addresses',
            (AddressEntity item) => <String, Object?>{
                  'id': item.id,
                  'user_id': item.userId,
                  'name': item.name,
                  'street': item.street,
                  'city': item.city,
                  'state': item.state,
                  'zip_code': item.zipCode,
                  'country': item.country
                },
            changeListener),
        _addressEntityUpdateAdapter = UpdateAdapter(
            database,
            'addresses',
            ['id'],
            (AddressEntity item) => <String, Object?>{
                  'id': item.id,
                  'user_id': item.userId,
                  'name': item.name,
                  'street': item.street,
                  'city': item.city,
                  'state': item.state,
                  'zip_code': item.zipCode,
                  'country': item.country
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AddressEntity> _addressEntityInsertionAdapter;

  final UpdateAdapter<AddressEntity> _addressEntityUpdateAdapter;

  @override
  Future<List<AddressEntity>> getAddressesByUserId(String userId) async {
    return _queryAdapter.queryList('SELECT * FROM addresses WHERE user_id = ?1',
        mapper: (Map<String, Object?> row) => AddressEntity(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            name: row['name'] as String,
            street: row['street'] as String,
            city: row['city'] as String,
            state: row['state'] as String,
            zipCode: row['zip_code'] as String,
            country: row['country'] as String),
        arguments: [userId]);
  }

  @override
  Stream<List<AddressEntity>> watchAddressesByUserId(String userId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM addresses WHERE user_id = ?1',
        mapper: (Map<String, Object?> row) => AddressEntity(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            name: row['name'] as String,
            street: row['street'] as String,
            city: row['city'] as String,
            state: row['state'] as String,
            zipCode: row['zip_code'] as String,
            country: row['country'] as String),
        arguments: [userId],
        queryableName: 'addresses',
        isView: false);
  }

  @override
  Future<AddressEntity?> getAddressById(String id) async {
    return _queryAdapter.query('SELECT * FROM addresses WHERE id = ?1',
        mapper: (Map<String, Object?> row) => AddressEntity(
            id: row['id'] as String,
            userId: row['user_id'] as String,
            name: row['name'] as String,
            street: row['street'] as String,
            city: row['city'] as String,
            state: row['state'] as String,
            zipCode: row['zip_code'] as String,
            country: row['country'] as String),
        arguments: [id]);
  }

  @override
  Future<void> deleteAddress(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM addresses WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertAddress(AddressEntity address) async {
    await _addressEntityInsertionAdapter.insert(
        address, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateAddress(AddressEntity address) async {
    await _addressEntityUpdateAdapter.update(
        address, OnConflictStrategy.replace);
  }
}

class _$OrderDao extends OrderDao {
  _$OrderDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _orderEntityInsertionAdapter = InsertionAdapter(
            database,
            'orders',
            (OrderEntity item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'shippingAddressId': item.shippingAddressId,
                  'paymentMethod': item.paymentMethod,
                  'subtotal': item.subtotal,
                  'shippingCost': item.shippingCost,
                  'tax': item.tax,
                  'total': item.total,
                  'status': item.status,
                  'orderDate': item.orderDate,
                  'estimatedDeliveryDate': item.estimatedDeliveryDate,
                  'notes': item.notes
                },
            changeListener),
        _orderItemEntityInsertionAdapter = InsertionAdapter(
            database,
            'order_items',
            (OrderItemEntity item) => <String, Object?>{
                  'id': item.id,
                  'orderId': item.orderId,
                  'productId': item.productId,
                  'productTitle': item.productTitle,
                  'productArtist': item.productArtist,
                  'productPrice': item.productPrice,
                  'productImageUrl': item.productImageUrl,
                  'quantity': item.quantity
                }),
        _orderEntityUpdateAdapter = UpdateAdapter(
            database,
            'orders',
            ['id'],
            (OrderEntity item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'shippingAddressId': item.shippingAddressId,
                  'paymentMethod': item.paymentMethod,
                  'subtotal': item.subtotal,
                  'shippingCost': item.shippingCost,
                  'tax': item.tax,
                  'total': item.total,
                  'status': item.status,
                  'orderDate': item.orderDate,
                  'estimatedDeliveryDate': item.estimatedDeliveryDate,
                  'notes': item.notes
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<OrderEntity> _orderEntityInsertionAdapter;

  final InsertionAdapter<OrderItemEntity> _orderItemEntityInsertionAdapter;

  final UpdateAdapter<OrderEntity> _orderEntityUpdateAdapter;

  @override
  Stream<List<OrderEntity>> watchOrdersByUserId(String userId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM orders WHERE userId = ?1 ORDER BY orderDate DESC',
        mapper: (Map<String, Object?> row) => OrderEntity(
            id: row['id'] as String,
            userId: row['userId'] as String,
            shippingAddressId: row['shippingAddressId'] as String,
            paymentMethod: row['paymentMethod'] as String,
            subtotal: row['subtotal'] as double,
            shippingCost: row['shippingCost'] as double,
            tax: row['tax'] as double,
            total: row['total'] as double,
            status: row['status'] as String,
            orderDate: row['orderDate'] as int,
            estimatedDeliveryDate: row['estimatedDeliveryDate'] as int?,
            notes: row['notes'] as String?),
        arguments: [userId],
        queryableName: 'orders',
        isView: false);
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    return _queryAdapter.query('SELECT * FROM orders WHERE id = ?1',
        mapper: (Map<String, Object?> row) => OrderEntity(
            id: row['id'] as String,
            userId: row['userId'] as String,
            shippingAddressId: row['shippingAddressId'] as String,
            paymentMethod: row['paymentMethod'] as String,
            subtotal: row['subtotal'] as double,
            shippingCost: row['shippingCost'] as double,
            tax: row['tax'] as double,
            total: row['total'] as double,
            status: row['status'] as String,
            orderDate: row['orderDate'] as int,
            estimatedDeliveryDate: row['estimatedDeliveryDate'] as int?,
            notes: row['notes'] as String?),
        arguments: [orderId]);
  }

  @override
  Future<List<OrderItemEntity>> getOrderItems(String orderId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM order_items WHERE orderId = ?1',
        mapper: (Map<String, Object?> row) => OrderItemEntity(
            id: row['id'] as int?,
            orderId: row['orderId'] as String,
            productId: row['productId'] as String,
            productTitle: row['productTitle'] as String,
            productArtist: row['productArtist'] as String,
            productPrice: row['productPrice'] as double,
            productImageUrl: row['productImageUrl'] as String?,
            quantity: row['quantity'] as int),
        arguments: [orderId]);
  }

  @override
  Future<void> insertOrder(OrderEntity order) async {
    await _orderEntityInsertionAdapter.insert(order, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertOrderItems(List<OrderItemEntity> items) async {
    await _orderItemEntityInsertionAdapter.insertList(
        items, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateOrder(OrderEntity order) async {
    await _orderEntityUpdateAdapter.update(order, OnConflictStrategy.abort);
  }
}

class _$AppSettingsDao extends AppSettingsDao {
  _$AppSettingsDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _appSettingsEntityInsertionAdapter = InsertionAdapter(
            database,
            'app_settings',
            (AppSettingsEntity item) =>
                <String, Object?>{'key': item.key, 'value': item.value});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AppSettingsEntity> _appSettingsEntityInsertionAdapter;

  @override
  Future<AppSettingsEntity?> getSetting(String key) async {
    return _queryAdapter.query('SELECT * FROM app_settings WHERE key = ?1',
        mapper: (Map<String, Object?> row) => AppSettingsEntity(
            key: row['key'] as String, value: row['value'] as String),
        arguments: [key]);
  }

  @override
  Future<void> deleteSetting(String key) async {
    await _queryAdapter.queryNoReturn('DELETE FROM app_settings WHERE key = ?1',
        arguments: [key]);
  }

  @override
  Future<void> insertSetting(AppSettingsEntity setting) async {
    await _appSettingsEntityInsertionAdapter.insert(
        setting, OnConflictStrategy.replace);
  }
}
