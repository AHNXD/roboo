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

  const StoreProductsLoading({
    required this.categories,
    required this.selectedIndex,
  });

  @override
  List<Object?> get props => [categories, selectedIndex];
}

final class StoreProductsError extends StoreState {
  final List<StoreCategoryModel> categories;
  final int selectedIndex;
  final String errorMsg;

  const StoreProductsError({
    required this.categories,
    required this.selectedIndex,
    required this.errorMsg,
  });

  @override
  List<Object?> get props => [categories, selectedIndex, errorMsg];
}

final class StoreLoaded extends StoreState {
  final List<StoreCategoryModel> categories;
  final List<StoreProductModel> products;
  final int selectedIndex;

  const StoreLoaded({
    required this.categories,
    required this.products,
    this.selectedIndex = 0,
  });

  @override
  List<Object?> get props => [categories, products, selectedIndex];
}

final class StoreEmpty extends StoreState {
  final List<StoreCategoryModel> categories;
  final int selectedIndex;

  const StoreEmpty({required this.categories, this.selectedIndex = 0});

  @override
  List<Object?> get props => [categories, selectedIndex];
}

final class StoreError extends StoreState {
  final String errorMsg;

  const StoreError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
