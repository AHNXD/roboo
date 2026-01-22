part of 'logout_cubit.dart';

sealed class LogoutState extends Equatable {
  const LogoutState();

  @override
  List<Object> get props => [];
}

final class LogoutInitial extends LogoutState {}

class LogoutLoading extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutError extends LogoutState {
  final String errorMsg;

  const LogoutError(this.errorMsg);

  @override
  List<Object> get props => [errorMsg];
}
