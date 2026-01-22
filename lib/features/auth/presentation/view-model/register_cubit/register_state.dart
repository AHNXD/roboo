part of 'register_cubit.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterError extends RegisterState {
  final String errorMsg;

  const RegisterError({required this.errorMsg});
}

final class RegisterSuccess extends RegisterState {
  final UserModel user;

  const RegisterSuccess({required this.user});
}
