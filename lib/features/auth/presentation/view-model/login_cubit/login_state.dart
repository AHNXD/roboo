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

/// Credentials were accepted but the email is still unverified: the screen
/// sends the user to the OTP screen instead of into the app.
final class LoginNeedsVerification extends LoginState {
  final String email;

  const LoginNeedsVerification({required this.email});

  @override
  List<Object> get props => [email];
}

final class LoginError extends LoginState {
  final String errorMsg;

  const LoginError({required this.errorMsg});
  @override
  List<Object> get props => [errorMsg];
}
