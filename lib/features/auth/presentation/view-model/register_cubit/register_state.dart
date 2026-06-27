part of 'register_cubit.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterVerificationLoading extends RegisterState {}

final class RegisterResendLoading extends RegisterState {}

final class RegisterError extends RegisterState {
  final String errorMsg;

  const RegisterError({required this.errorMsg});

  @override
  List<Object> get props => [errorMsg];
}

final class RegisterSuccess extends RegisterState {
  final RegisterResponseModel registerResponse;

  const RegisterSuccess({required this.registerResponse});

  @override
  List<Object> get props => [registerResponse];
}

final class RegisterVerificationSuccess extends RegisterState {
  final LoginResponseModel loginResponse;

  const RegisterVerificationSuccess({required this.loginResponse});

  @override
  List<Object> get props => [loginResponse];
}

final class RegisterResendSuccess extends RegisterState {
  final String message;

  const RegisterResendSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
