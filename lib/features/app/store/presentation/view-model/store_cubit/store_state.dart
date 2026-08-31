part of 'store_cubit.dart';

sealed class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

final class StoreInitial extends StoreState {}

final class StoreLoading extends StoreState {}

final class StoreProductsLoading extends StoreState {
  final List<StoreCategoryModel> categories;
  final int selectedIndex;
  final String searchQuery;

  const StoreProductsLoading({
    required this.categories,
    required this.selectedIndex,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [categories, selectedIndex, searchQuery];
}

final class StoreProductsError extends StoreState {
  final List<StoreCategoryModel> categories;
  final int selectedIndex;
  final String errorMsg;

  final String searchQuery;

  const StoreProductsError({
    required this.categories,
    required this.selectedIndex,
    required this.errorMsg,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [categories, selectedIndex, errorMsg, searchQuery];
}

final class StoreLoaded extends StoreState {
  final List<StoreCategoryModel> categories;
  final List<StoreProductModel> products;
  final int selectedIndex;

  final String searchQuery;

  /// Another page exists on the server.
  final bool hasMore;

  /// That next page is being fetched right now.
  final bool isLoadingMore;

  const StoreLoaded({
    required this.categories,
    required this.products,
    this.selectedIndex = 0,
    this.searchQuery = '',
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
    categories,
    products,
    selectedIndex,
    searchQuery,
    hasMore,
    isLoadingMore,
  ];
}

final class StoreEmpty extends StoreState {
  final List<StoreCategoryModel> categories;
  final int selectedIndex;
  final String searchQuery;

  const StoreEmpty({
    required this.categories,
    this.selectedIndex = 0,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [categories, selectedIndex, searchQuery];
}

final class StoreError extends StoreState {
  final String errorMsg;

  const StoreError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
