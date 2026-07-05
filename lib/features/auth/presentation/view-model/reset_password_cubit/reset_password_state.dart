part of 'reset_password_cubit.dart';

sealed class ResetPasswordState extends Equatable {
  const ResetPasswordState();

  @override
  List<Object> get props => [];
}

final class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordResendLoading extends ResetPasswordState {}

class PasswordResetCodeSent extends ResetPasswordState {
  final String message;
  const PasswordResetCodeSent({required this.message});

  @override
  List<Object> get props => [message];
}

class ResetPasswordError extends ResetPasswordState {
  final String errorMsg;
  const ResetPasswordError({required this.errorMsg});

  @override
  List<Object> get props => [errorMsg];
}

class ResetPasswordSuccess extends ResetPasswordState {
  final LoginResponseModel loginResponse;

  const ResetPasswordSuccess({required this.loginResponse});

  @override
  List<Object> get props => [loginResponse];
}

class ResendCodeSuccess extends ResetPasswordState {
  final String message;

  const ResendCodeSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
