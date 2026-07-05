import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/login_response_model.dart';
import '../../../data/repos/reset_password_repo/reset_password_repo.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordRepo _resetPasswordRepo;
  ResetPasswordCubit(this._resetPasswordRepo) : super(ResetPasswordInitial());

  Future<void> requestPasswordReset({required String email}) async {
    emit(ResetPasswordLoading());
    final result = await _resetPasswordRepo.requestPasswordReset(email: email);
    result.fold(
      (failure) => emit(ResetPasswordError(errorMsg: failure.message)),
      (message) => emit(PasswordResetCodeSent(message: message)),
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(ResetPasswordLoading());
    final result = await _resetPasswordRepo.resetPassword(
      email: email,
      code: code,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failure) => emit(ResetPasswordError(errorMsg: failure.message)),
      (loginResponse) =>
          emit(ResetPasswordSuccess(loginResponse: loginResponse)),
    );
  }

  Future<void> resendCode({required String email}) async {
    emit(ResetPasswordResendLoading());
    final result = await _resetPasswordRepo.requestPasswordReset(email: email);
    result.fold(
      (failure) => emit(ResetPasswordError(errorMsg: failure.message)),
      (message) => emit(ResendCodeSuccess(message: message)),
    );
  }
}
