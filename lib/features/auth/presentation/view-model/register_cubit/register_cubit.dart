import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/login_response_model.dart';
import '../../../data/models/register_request_model.dart';
import '../../../data/models/register_response_model.dart';
import '../../../data/repos/register_repo/register_repo.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registerRepo) : super(RegisterInitial());

  final RegisterRepo _registerRepo;

  Future<void> register(RegisterRequestModel request) async {
    emit(RegisterLoading());
    final data = await _registerRepo.register(request);
    data.fold((failure) => emit(RegisterError(errorMsg: failure.message)), (
      registerResponse,
    ) {
      emit(RegisterSuccess(registerResponse: registerResponse));
    });
  }

  Future<void> verifyAccount({
    required String email,
    required String code,
  }) async {
    emit(RegisterVerificationLoading());
    final data = await _registerRepo.verifyAccount(email: email, code: code);
    data.fold((failure) => emit(RegisterError(errorMsg: failure.message)), (
      loginResponse,
    ) {
      emit(RegisterVerificationSuccess(loginResponse: loginResponse));
    });
  }

  Future<void> resendVerification({required String email}) async {
    emit(RegisterResendLoading());
    final data = await _registerRepo.resendVerification(email: email);
    data.fold(
      (failure) => emit(RegisterError(errorMsg: failure.message)),
      (message) => emit(RegisterResendSuccess(message: message)),
    );
  }
}
