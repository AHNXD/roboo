import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/logout_repo/logout_repo.dart';

part 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final LogoutRepo logoutRepo;
  LogoutCubit(this.logoutRepo) : super(LogoutInitial());

  /// Irreversible. The screen must confirm with the user before calling this.
  Future<void> deleteAccount() async {
    emit(LogoutLoading());
    final result = await logoutRepo.deleteAccount();
    result.fold(
      (failure) => emit(LogoutError(failure.message)),
      (_) => emit(AccountDeleted()),
    );
  }

  Future<void> logout() async {
    emit(LogoutLoading());
    final result = await logoutRepo.logout();
    result.fold(
      (failure) => emit(LogoutError(failure.message)),
      (_) => emit(LogoutSuccess()),
    );
  }
}
