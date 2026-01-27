import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/error/failures.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';

import 'product_detail_event.dart';
import 'product_detail_state.dart';

export 'product_detail_event.dart';
export 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({required GetProductById getProductById})
      : _getProductById = getProductById,
        super(const ProductDetailInitial()) {
    on<ProductDetailFetched>(_onFetched);
  }

  final GetProductById _getProductById;

  Future<void> _onFetched(
    ProductDetailFetched event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailLoading());

    final result = await _getProductById(
      GetProductByIdParams(id: event.productId),
    );

    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          emit(const ProductDetailNotFound());
        } else {
          emit(ProductDetailError(failure.message));
        }
      },
      (product) => emit(ProductDetailLoaded(product)),
    );
  }
}
