part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginSuccess extends LoginState {
  final String role;
  const LoginSuccess({required this.role});
  @override
  List<Object> get props => [role];
}

final class LoginLoading extends LoginState {}

final class LoginError extends LoginState {
  final String errorMsg;

  const LoginError({required this.errorMsg});
  @override
  List<Object> get props => [errorMsg];
}
