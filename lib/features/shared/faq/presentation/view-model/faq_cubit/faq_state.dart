part of 'faq_cubit.dart';

sealed class FaqState extends Equatable {
  const FaqState();

  @override
  List<Object?> get props => [];
}

final class FaqInitial extends FaqState {}

final class FaqLoading extends FaqState {}

final class FaqEmpty extends FaqState {}

final class FaqLoaded extends FaqState {
  final List<FaqModel> faqs;

  const FaqLoaded({required this.faqs});

  @override
  List<Object?> get props => [faqs];
}

final class FaqError extends FaqState {
  final String errorMsg;

  const FaqError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
