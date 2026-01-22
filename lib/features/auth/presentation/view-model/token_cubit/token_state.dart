part of 'token_cubit.dart';

sealed class TokenState extends Equatable {
  const TokenState();

  @override
  List<Object> get props => [];
}

final class TokenInitial extends TokenState {}

final class IsVaildToken extends TokenState {}

final class IsNotVaildToken extends TokenState {}

final class TokenLoadingState extends TokenState {}

final class IsFirstUseTrue extends TokenState {}

final class IsFirstUseFalse extends TokenState {}

final class TokenErrorState extends TokenState {
  final String errorMsg;
  const TokenErrorState(this.errorMsg);
}
