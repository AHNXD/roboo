part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginSuccess extends LoginState {
  final LoginResponseModel loginResponse;
  const LoginSuccess({required this.loginResponse});
  @override
  List<Object> get props => [loginResponse];
}

final class LoginLoading extends LoginState {}

final class LoginError extends LoginState {
  final String errorMsg;

  const LoginError({required this.errorMsg});
  @override
  List<Object> get props => [errorMsg];
}
