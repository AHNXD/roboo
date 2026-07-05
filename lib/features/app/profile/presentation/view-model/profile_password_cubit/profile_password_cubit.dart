import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/profile_password_update_response_model.dart';
import '../../../data/repos/profile_password_repo.dart';

part 'profile_password_state.dart';

class ProfilePasswordCubit extends Cubit<ProfilePasswordState> {
  final ProfilePasswordRepo _profilePasswordRepo;

  ProfilePasswordCubit(this._profilePasswordRepo)
    : super(ProfilePasswordInitial());

  Future<void> requestPasswordUpdateCode() async {
    emit(ProfilePasswordLoading());
    final result = await _profilePasswordRepo.requestPasswordUpdateCode();
    result.fold(
      (failure) => emit(ProfilePasswordError(errorMsg: failure.message)),
      (message) => emit(ProfilePasswordCodeSent(message: message)),
    );
  }

  Future<void> resendPasswordUpdateCode() async {
    emit(ProfilePasswordResendLoading());
    final result = await _profilePasswordRepo.requestPasswordUpdateCode();
    result.fold(
      (failure) => emit(ProfilePasswordError(errorMsg: failure.message)),
      (message) => emit(ProfilePasswordCodeResent(message: message)),
    );
  }

  Future<void> updatePassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(ProfilePasswordLoading());
    final result = await _profilePasswordRepo.updatePassword(
      code: code,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failure) => emit(ProfilePasswordError(errorMsg: failure.message)),
      (response) => emit(ProfilePasswordUpdateSuccess(response: response)),
    );
  }
}
