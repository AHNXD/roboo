part of 'legal_content_cubit.dart';

sealed class LegalContentState extends Equatable {
  const LegalContentState();

  @override
  List<Object?> get props => [];
}

final class LegalContentInitial extends LegalContentState {}

final class LegalContentLoading extends LegalContentState {}

final class LegalContentEmpty extends LegalContentState {}

final class LegalContentLoaded extends LegalContentState {
  final LegalContentModel content;

  const LegalContentLoaded({required this.content});

  @override
  List<Object?> get props => [content];
}

final class LegalContentError extends LegalContentState {
  final String errorMsg;

  const LegalContentError({required this.errorMsg});

  @override
  List<Object?> get props => [errorMsg];
}
