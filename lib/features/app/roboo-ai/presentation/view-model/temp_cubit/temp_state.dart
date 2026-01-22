part of 'temp_cubit.dart';

sealed class TempState extends Equatable {
  const TempState();

  @override
  List<Object> get props => [];
}

final class TempInitial extends TempState {}

final class TempLoading extends TempState {}

final class TempError extends TempState {
  final String errorMsg;

  const TempError({required this.errorMsg});
  @override
  List<Object> get props => [errorMsg];
}

final class TempSuccess extends TempState {}
