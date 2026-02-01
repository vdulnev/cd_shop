import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';
import 'package:cd_shop/features/product/presentation/providers/product_detail_state.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailNotifier extends Notifier<ProductDetailState> {
  ProductDetailNotifier(this._productId);

  final String _productId;
  late final GetProductById _getProductById;

  @override
  ProductDetailState build() {
    _getProductById = sl<GetProductById>();
    _load(_productId);
    return const ProductDetailLoading();
  }

  Future<void> _load(String productId) async {
    try {
      final product = await _getProductById(
        GetProductByIdParams(id: productId),
      );
      if (product == null) {
        state = const ProductDetailNotFound();
      } else {
        state = ProductDetailLoaded(product);
      }
    } catch (error) {
      state = ProductDetailError(error.toString());
    }
  }
}

final productDetailProvider =
    NotifierProvider.family<ProductDetailNotifier, ProductDetailState, String>(
  (productId) => ProductDetailNotifier(productId),
);
