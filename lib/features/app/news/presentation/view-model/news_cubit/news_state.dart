part of 'news_cubit.dart';

sealed class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

final class NewsInitial extends NewsState {
  const NewsInitial();
}

final class NewsLoading extends NewsState {
  const NewsLoading();
}

final class NewsLoaded extends NewsState {
  final List<NewsGalleryModel> galleries;

  const NewsLoaded({required this.galleries});

  @override
  List<Object?> get props => [galleries];
}

final class NewsEmpty extends NewsState {
  const NewsEmpty();
}

final class NewsError extends NewsState {
  final String errorMsg;

  const NewsError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
