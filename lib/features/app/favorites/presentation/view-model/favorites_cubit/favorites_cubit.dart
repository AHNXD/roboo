import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/favorite_product_model.dart';
import '../../../data/repos/favorites_repo.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepo _favoritesRepo;

  List<FavoriteProductModel> _products = const [];
  Set<int> _favoriteIds = <int>{};
  Map<int, bool> _favoriteOverrides = <int, bool>{};
  bool _hasLoaded = false;

  FavoritesCubit(this._favoritesRepo) : super(FavoritesInitial());

  Future<void> loadFavorites({bool force = false}) async {
    if (_hasLoaded && !force) return;

    emit(
      FavoritesLoading(
        products: _products,
        favoriteIds: _favoriteIds,
        favoriteOverrides: _favoriteOverrides,
      ),
    );

    final result = await _favoritesRepo.getFavorites();
    result.fold(
      (failure) => emit(
        FavoritesError(
          errorMsg: failure.message,
          products: _products,
          favoriteIds: _favoriteIds,
          favoriteOverrides: _favoriteOverrides,
        ),
      ),
      (page) {
        // Page 1 only: this cubit is an app-wide singleton whose favourite-id
        // set backs the heart on every product card, so it is not paged.
        final products = page.items;
        _hasLoaded = true;
        _products = products;
        _favoriteIds = products
            .map((product) => product.id)
            .whereType<int>()
            .toSet();
        _favoriteOverrides = <int, bool>{};

        if (_products.isEmpty) {
          emit(
            FavoritesEmpty(
              products: _products,
              favoriteIds: _favoriteIds,
              favoriteOverrides: _favoriteOverrides,
            ),
          );
          return;
        }

        emit(
          FavoritesLoaded(
            products: _products,
            favoriteIds: _favoriteIds,
            favoriteOverrides: _favoriteOverrides,
          ),
        );
      },
    );
  }

  Future<void> refreshFavorites() => loadFavorites(force: true);

  Future<void> toggleFavorite(int? productId) async {
    if (productId == null) {
      emit(
        FavoriteToggleError(
          errorMsg: 'favorite_product_unavailable',
          products: _products,
          favoriteIds: _favoriteIds,
          favoriteOverrides: _favoriteOverrides,
        ),
      );
      return;
    }

    emit(
      FavoriteToggleLoading(
        productId: productId,
        products: _products,
        favoriteIds: _favoriteIds,
        favoriteOverrides: _favoriteOverrides,
      ),
    );

    final result = await _favoritesRepo.toggleFavorite(productId: productId);
    result.fold(
      (failure) => emit(
        FavoriteToggleError(
          errorMsg: failure.message,
          products: _products,
          favoriteIds: _favoriteIds,
          favoriteOverrides: _favoriteOverrides,
        ),
      ),
      (response) {
        final updatedFavoriteIds = Set<int>.from(_favoriteIds)
          ..addAll(response.attached)
          ..removeAll(response.detached);
        final detachedIds = response.detached.toSet();
        final attachedIds = response.attached.toSet();

        _favoriteIds = updatedFavoriteIds;
        final isNowFavorite =
            attachedIds.contains(productId) ||
            (!detachedIds.contains(productId) &&
                _favoriteIds.contains(productId));
        _favoriteOverrides = {..._favoriteOverrides, productId: isNowFavorite};
        if (detachedIds.isNotEmpty) {
          _products = _products
              .where((product) => !detachedIds.contains(product.id))
              .toList();
        }

        emit(
          FavoriteToggleSuccess(
            productId: productId,
            isNowFavorite: isNowFavorite,
            products: _products,
            favoriteIds: _favoriteIds,
            favoriteOverrides: _favoriteOverrides,
          ),
        );
      },
    );
  }
}
