import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/core/models/analytics_event.dart';
import 'package:cd_shop/core/services/analytics_event_bus.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/presentation/providers/product_detail_state.dart';
import 'package:cd_shop/injection_container.dart';

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier({
    required GetProductById getProductById,
    required String productId,
    required AnalyticsEventBus analyticsEventBus,
  }) : _getProductById = getProductById,
       _productId = productId,
       _analyticsEventBus = analyticsEventBus,
       super(const ProductDetailInitial()) {
    _fetchProduct();
  }

  final GetProductById _getProductById;
  final String _productId;
  final AnalyticsEventBus _analyticsEventBus;

  Future<void> _fetchProduct() async {
    state = const ProductDetailLoading();
    final product = await _getProductById(GetProductByIdParams(id: _productId));
    if (product != null) {
      _analyticsEventBus.emit(ViewProductAnalyticsEvent(product: product));
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
        analyticsEventBus: sl<AnalyticsEventBus>(),
      );
    });
