import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/presentation/providers/product_detail_state.dart';
import 'package:cd_shop/injection_container.dart';

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier({
    required GetProductById getProductById,
    required String productId,
    required AnalyticsService analyticsService,
  }) : _getProductById = getProductById,
       _productId = productId,
       _analyticsService = analyticsService,
       super(const ProductDetailInitial()) {
    _fetchProduct();
  }

  final GetProductById _getProductById;
  final String _productId;
  final AnalyticsService _analyticsService;

  Future<void> _fetchProduct() async {
    state = const ProductDetailLoading();
    final product = await _getProductById(GetProductByIdParams(id: _productId));
    if (product != null) {
      _analyticsService.logViewProduct(product);
      state = ProductDetailLoaded(product);
    } else {
      state = const ProductDetailNotFound();
    }
  }
}

final productDetailProvider = StateNotifierProvider.autoDispose
    .family<ProductDetailNotifier, ProductDetailState, String>((
      ref,
      productId,
    ) {
      return ProductDetailNotifier(
        getProductById: sl<GetProductById>(),
        productId: productId,
        analyticsService: sl<AnalyticsService>(),
      );
    });
