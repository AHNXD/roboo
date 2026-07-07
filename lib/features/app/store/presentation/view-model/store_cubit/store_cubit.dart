import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/store_category_model.dart';
import '../../../data/models/store_product_model.dart';
import '../../../data/repos/store_repo.dart';

part 'store_state.dart';

class StoreCubit extends Cubit<StoreState> {
  final StoreRepo _storeRepo;

  StoreCubit(this._storeRepo) : super(StoreInitial());

  Future<void> getStoreData() async {
    emit(StoreLoading());

    final categoriesResult = await _storeRepo.getCategories();
    final productsResult = await _storeRepo.getProducts();

    final categoryFailure = categoriesResult.fold(
      (failure) => failure,
      (_) => null,
    );
    if (categoryFailure != null) {
      emit(StoreError(errorMsg: categoryFailure.message));
      return;
    }

    final productFailure = productsResult.fold(
      (failure) => failure,
      (_) => null,
    );
    if (productFailure != null) {
      emit(StoreError(errorMsg: productFailure.message));
      return;
    }

    final categories = categoriesResult.getOrElse(() => const []);
    final products = productsResult.getOrElse(() => const []);

    if (products.isEmpty) {
      emit(StoreEmpty(categories: categories));
      return;
    }

    emit(StoreLoaded(categories: categories, products: products));
  }

  Future<void> selectCategory(int selectedIndex) async {
    final currentState = state;
    if (currentState is! StoreLoaded &&
        currentState is! StoreEmpty &&
        currentState is! StoreProductsLoading &&
        currentState is! StoreProductsError) {
      return;
    }

    final categories = switch (currentState) {
      StoreLoaded(:final categories) => categories,
      StoreEmpty(:final categories) => categories,
      StoreProductsLoading(:final categories) => categories,
      StoreProductsError(:final categories) => categories,
      _ => const <StoreCategoryModel>[],
    };

    final categoryId = _categoryIdForIndex(
      categories: categories,
      selectedIndex: selectedIndex,
    );

    if (selectedIndex != 0 && categoryId == null) {
      return;
    }

    emit(
      StoreProductsLoading(
        categories: categories,
        selectedIndex: selectedIndex,
      ),
    );

    final productsResult = await _storeRepo.getProducts(categoryId: categoryId);
    productsResult.fold(
      (failure) => emit(
        StoreProductsError(
          categories: categories,
          selectedIndex: selectedIndex,
          errorMsg: failure.message,
        ),
      ),
      (products) {
        if (products.isEmpty) {
          emit(
            StoreEmpty(categories: categories, selectedIndex: selectedIndex),
          );
          return;
        }

        emit(
          StoreLoaded(
            categories: categories,
            products: products,
            selectedIndex: selectedIndex,
          ),
        );
      },
    );
  }

  int? _categoryIdForIndex({
    required List<StoreCategoryModel> categories,
    required int selectedIndex,
  }) {
    if (selectedIndex == 0) return null;

    final categoryIndex = selectedIndex - 1;
    if (categoryIndex < 0 || categoryIndex >= categories.length) return null;

    return categories[categoryIndex].id;
  }
}
