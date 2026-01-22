import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/features/product/domain/entities/product.dart';
import 'package:cd_shop/features/product/domain/usecases/get_product_by_id.dart';

import '../../../../core/error/failures.dart';

// Events
sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailFetched extends ProductDetailEvent {
  const ProductDetailFetched(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

// States
sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

class ProductDetailLoaded extends ProductDetailState {
  const ProductDetailLoaded(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends ProductDetailState {
  const ProductDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ProductDetailNotFound extends ProductDetailState {
  const ProductDetailNotFound();
}

// Bloc
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
