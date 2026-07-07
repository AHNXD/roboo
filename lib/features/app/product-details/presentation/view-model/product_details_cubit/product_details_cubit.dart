import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/error_handler.dart';
import '../../../data/models/product_details_model.dart';
import '../../../data/repos/product_details_repo.dart';

part 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final ProductDetailsRepo _productDetailsRepo;

  ProductDetailsCubit(this._productDetailsRepo)
    : super(ProductDetailsInitial());

  Future<void> getProductDetails(int? productId) async {
    if (productId == null) {
      emit(ProductDetailsError(errorMsg: ErrorHandler.defaultMessage()));
      return;
    }

    emit(ProductDetailsLoading());

    final result = await _productDetailsRepo.getProductDetails(
      productId: productId,
    );
    result.fold(
      (failure) => emit(ProductDetailsError(errorMsg: failure.message)),
      (product) => emit(ProductDetailsLoaded(product: product)),
    );
  }
}
