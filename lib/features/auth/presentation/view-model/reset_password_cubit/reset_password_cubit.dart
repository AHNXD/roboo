import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repos/reset_password_repo/reset_password_repo.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordRepo _resetPasswordRepo;
  String password = "";
  ResetPasswordCubit(this._resetPasswordRepo) : super(ResetPasswordInitial());

  Future<void> resetPassword({required String phone}) async {
    emit(ResetPasswordLoading());
    final result = await _resetPasswordRepo.resetPassword(phone: phone);
    result.fold(
      (failure) => emit(ResetPasswordError(errorMsg: failure.message)),
      (phone) => emit(ResetPasswordSuccess(phone: phone)),
    );
  }

  void verifyResetPassword({
    required String phone,
    required String code,
  }) async {
    emit(ResetPasswordLoading());
    final result = await _resetPasswordRepo.verifyResetPassword(
      phone: phone,
      code: code,
      password: password,
    );
    result.fold(
      (failure) => emit(ResetPasswordError(errorMsg: failure.message)),
      (message) => emit(VerifyResetPasswordSuccess(message: message)),
    );
  }

  void resendCode({required String phone}) async {
    final result = await _resetPasswordRepo.resendCode(phone: phone);

    result.fold(
      (failure) => emit(ResetPasswordError(errorMsg: failure.message)),
      (message) => emit(ResendCodeSuccess()),
    );
  }
}
