import 'package:cd_shop/core/database/daos/app_settings_dao.dart';
import 'package:cd_shop/core/database/daos/product_dao.dart';
import 'package:cd_shop/core/database/entities/app_settings_entity.dart';
import 'package:cd_shop/core/database/entities/product_entity.dart';
import 'package:cd_shop/core/models/analytics_event.dart';
import 'package:cd_shop/core/models/disposable.dart';
import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/features/product/data/datasources/product_mock_datasource.dart';
import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/repositories/product_repository.dart';

/// Floor database implementation of ProductRepository
///
/// Persists products to SQLite using Floor.
/// Seeds database with mock data on first launch.
class ProductRepositoryImpl
  with EventEmitterMixin, AnalyticsEventBusMixin
  implements ProductRepository, EventEmitter, Disposable {
  ProductRepositoryImpl({
    required ProductDao productDao,
    required AppSettingsDao appSettingsDao,
  })  : _productDao = productDao,
        _appSettingsDao = appSettingsDao {
    _initialize();
  }

  final ProductDao _productDao;
  final AppSettingsDao _appSettingsDao;

  static const _productsSeededKey = 'products_seeded';

  /// Seed database with mock data on first launch (non-blocking)
  Future<void> _initialize() async {
    final setting = await _appSettingsDao.getSetting(_productsSeededKey);
    if (setting == null) {
      final mockProducts = ProductMockDataSource.getAll();
      final entities = mockProducts.map(ProductEntity.fromDomain).toList();
      await _productDao.insertProducts(entities);

      await _appSettingsDao.insertSetting(
        const AppSettingsEntity(key: _productsSeededKey, value: 'true'),
      );
    }
  }
  
  @override
  void dispose() {
    disposeEventEmitter();
    disposeAnalyticsEmitter();
  }

  @override
  Future<List<Product>> getProducts({
    ProductGenre? genre,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    List<ProductEntity> entities;

    if (genre != null) {
      entities = await _productDao.getProductsByGenre(genre.name);
    } else if (searchQuery != null && searchQuery.isNotEmpty) {
      entities = await _productDao.searchProducts('%$searchQuery%');
    } else {
      entities = await _productDao.getAllProducts();
    }

    List<Product> results = entities.map((e) => e.toDomain()).toList();

    if (offset != null && offset > 0) {
      results = results.skip(offset).toList();
    }

    if (limit != null && limit > 0) {
      results = results.take(limit).toList();
    }

    return results;
  }

  @override
  Future<Product?> getProductById(String id) async {
    final entity = await _productDao.getProductById(id);
    final product = entity?.toDomain();
    if (product != null) {
      emitAnalyticsEvent(ViewProductAnalyticsEvent(product: product));
    }
    return product;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    emitAnalyticsEvent(SearchAnalyticsEvent(query: query));
    final entities = await _productDao.searchProducts('%$query%');
    return entities.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Product>> getProductsByGenre(ProductGenre genre) async {
    final entities = await _productDao.getProductsByGenre(genre.name);
    return entities.map((e) => e.toDomain()).toList();
  }

  @override
  Future<List<Product>> getFeaturedProducts() async {
    final entities = await _productDao.getFeaturedProducts(6);
    return entities.map((e) => e.toDomain()).toList();
  }

  @override
  Stream<List<Product>> watchProducts() {
    return _productDao.watchAllProducts().map(
      (entities) => entities.map((e) => e.toDomain()).toList(),
    );
  }
}
