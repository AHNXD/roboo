import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';
import '../../../data/models/store_category_model.dart';
import '../../../data/models/store_product_model.dart';
import '../../../data/repos/store_repo.dart';

part 'store_state.dart';

class StoreCubit extends Cubit<StoreState> with SafeEmit<StoreState> {
  final StoreRepo _storeRepo;

  StoreCubit(this._storeRepo) : super(StoreInitial());

  /// Long enough that typing a word is one request rather than one per letter,
  /// short enough that the grid still feels like it reacts to typing.
  static const Duration _searchDebounce = Duration(milliseconds: 400);

  Timer? _debounceTimer;
  List<StoreCategoryModel> _categories = const [];
  int _selectedIndex = 0;
  String _query = '';
  List<StoreProductModel> _products = const [];
  PaginationModel _pagination = PaginationModel.single;
  bool _isLoadingMore = false;

  Future<void> getStoreData() async {
    safeEmit(StoreLoading());

    final categoriesResult = await _storeRepo.getCategories();

    final categoryFailure = categoriesResult.fold(
      (failure) => failure,
      (_) => null,
    );
    if (categoryFailure != null) {
      safeEmit(StoreError(errorMsg: categoryFailure.message));
      return;
    }

    _categories = categoriesResult.getOrElse(() => const []);

    final productsResult = await _storeRepo.getProducts();

    productsResult.fold(
      (failure) => safeEmit(StoreError(errorMsg: failure.message)),
      (page) {
        _products = page.items;
        _pagination = page.pagination;
        safeEmit(
          _products.isEmpty
              ? StoreEmpty(categories: _categories)
              : StoreLoaded(
                  categories: _categories,
                  products: _products,
                  hasMore: page.hasMore,
                ),
        );
      },
    );
  }

  /// Appends the next page. Failures here are deliberately quiet: the list the
  /// user is already reading stays on screen, and scrolling again retries.
  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_pagination.hasMore) return;

    _isLoadingMore = true;
    safeEmit(
      StoreLoaded(
        categories: _categories,
        products: _products,
        selectedIndex: _selectedIndex,
        searchQuery: _query,
        hasMore: true,
        isLoadingMore: true,
      ),
    );

    final result = await _storeRepo.getProducts(
      categoryId: _categoryIdForIndex(_selectedIndex),
      search: _query.isEmpty ? null : _query,
      page: _pagination.nextPage,
    );

    _isLoadingMore = false;

    result.fold(
      (_) => safeEmit(
        StoreLoaded(
          categories: _categories,
          products: _products,
          selectedIndex: _selectedIndex,
          searchQuery: _query,
          hasMore: _pagination.hasMore,
        ),
      ),
      (page) {
        _products = [..._products, ...page.items];
        _pagination = page.pagination;
        safeEmit(
          StoreLoaded(
            categories: _categories,
            products: _products,
            selectedIndex: _selectedIndex,
            searchQuery: _query,
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }

  Future<void> selectCategory(int selectedIndex) async {
    if (selectedIndex != 0 && _categoryIdForIndex(selectedIndex) == null) {
      return;
    }

    _selectedIndex = selectedIndex;
    await _loadProducts();
  }

  /// Debounced: the request goes out once the user stops typing.
  void search(String query) {
    final trimmed = query.trim();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_searchDebounce, () {
      if (trimmed == _query) return;
      _query = trimmed;
      _loadProducts();
    });
  }

  /// Clearing the field should feel instant, so it skips the debounce.
  void clearSearch() {
    _debounceTimer?.cancel();
    if (_query.isEmpty) return;

    _query = '';
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    safeEmit(
      StoreProductsLoading(
        categories: _categories,
        selectedIndex: _selectedIndex,
        searchQuery: _query,
      ),
    );

    // A new filter starts a new list, so page 1 replaces rather than appends.
    final productsResult = await _storeRepo.getProducts(
      categoryId: _categoryIdForIndex(_selectedIndex),
      search: _query.isEmpty ? null : _query,
    );

    productsResult.fold(
      (failure) => safeEmit(
        StoreProductsError(
          categories: _categories,
          selectedIndex: _selectedIndex,
          searchQuery: _query,
          errorMsg: failure.message,
        ),
      ),
      (page) {
        _products = page.items;
        _pagination = page.pagination;
        safeEmit(
          _products.isEmpty
              ? StoreEmpty(
                  categories: _categories,
                  selectedIndex: _selectedIndex,
                  searchQuery: _query,
                )
              : StoreLoaded(
                  categories: _categories,
                  products: _products,
                  selectedIndex: _selectedIndex,
                  searchQuery: _query,
                  hasMore: page.hasMore,
                ),
        );
      },
    );
  }

  int? _categoryIdForIndex(int selectedIndex) {
    if (selectedIndex == 0) return null;

    final categoryIndex = selectedIndex - 1;
    if (categoryIndex < 0 || categoryIndex >= _categories.length) return null;

    return _categories[categoryIndex].id;
  }

  @override
  Future<void> close() {
    // A pending debounce would otherwise fire into a closed cubit.
    _debounceTimer?.cancel();
    return super.close();
  }
}
