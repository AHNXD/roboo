part of 'favorites_cubit.dart';

sealed class FavoritesState extends Equatable {
  final List<FavoriteProductModel> products;
  final Set<int> favoriteIds;

  const FavoritesState({required this.products, required this.favoriteIds});

  bool isFavorite(int? productId) {
    return productId != null && favoriteIds.contains(productId);
  }

  @override
  List<Object?> get props => [products, favoriteIds.toList()];
}

final class FavoritesInitial extends FavoritesState {
  const FavoritesInitial() : super(products: const [], favoriteIds: const {});
}

final class FavoritesLoading extends FavoritesState {
  const FavoritesLoading({required super.products, required super.favoriteIds});
}

final class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({required super.products, required super.favoriteIds});
}

final class FavoritesEmpty extends FavoritesState {
  const FavoritesEmpty({required super.products, required super.favoriteIds});
}

final class FavoritesError extends FavoritesState {
  final String errorMsg;

  const FavoritesError({
    required this.errorMsg,
    required super.products,
    required super.favoriteIds,
  });

  @override
  List<Object?> get props => [...super.props, errorMsg];
}

final class FavoriteToggleLoading extends FavoritesState {
  final int productId;

  const FavoriteToggleLoading({
    required this.productId,
    required super.products,
    required super.favoriteIds,
  });

  @override
  List<Object?> get props => [...super.props, productId];
}

final class FavoriteToggleSuccess extends FavoritesState {
  final int productId;
  final bool isNowFavorite;

  const FavoriteToggleSuccess({
    required this.productId,
    required this.isNowFavorite,
    required super.products,
    required super.favoriteIds,
  });

  @override
  List<Object?> get props => [...super.props, productId, isNowFavorite];
}

final class FavoriteToggleError extends FavoritesState {
  final String errorMsg;

  const FavoriteToggleError({
    required this.errorMsg,
    required super.products,
    required super.favoriteIds,
  });

  @override
  List<Object?> get props => [...super.props, errorMsg];
}
