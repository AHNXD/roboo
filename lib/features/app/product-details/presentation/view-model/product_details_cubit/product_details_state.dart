part of 'product_details_cubit.dart';

sealed class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailsInitial extends ProductDetailsState {}

final class ProductDetailsLoading extends ProductDetailsState {}

final class ProductDetailsLoaded extends ProductDetailsState {
  final ProductDetailsModel product;

  const ProductDetailsLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

final class ProductDetailsError extends ProductDetailsState {
  final String errorMsg;

  const ProductDetailsError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
