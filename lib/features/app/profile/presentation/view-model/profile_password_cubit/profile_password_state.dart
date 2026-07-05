part of 'profile_password_cubit.dart';

sealed class ProfilePasswordState extends Equatable {
  const ProfilePasswordState();

  @override
  List<Object> get props => [];
}

final class ProfilePasswordInitial extends ProfilePasswordState {}

final class ProfilePasswordLoading extends ProfilePasswordState {}

final class ProfilePasswordResendLoading extends ProfilePasswordState {}

final class ProfilePasswordCodeSent extends ProfilePasswordState {
  final String message;

  const ProfilePasswordCodeSent({required this.message});

  @override
  List<Object> get props => [message];
}

final class ProfilePasswordCodeResent extends ProfilePasswordState {
  final String message;

  const ProfilePasswordCodeResent({required this.message});

  @override
  List<Object> get props => [message];
}

final class ProfilePasswordUpdateSuccess extends ProfilePasswordState {
  final ProfilePasswordUpdateResponseModel response;

  const ProfilePasswordUpdateSuccess({required this.response});

  @override
  List<Object> get props => [response];
}

final class ProfilePasswordError extends ProfilePasswordState {
  final String errorMsg;

  const ProfilePasswordError({required this.errorMsg});

  @override
  List<Object> get props => [errorMsg];
}
