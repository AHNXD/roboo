import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/login_response_model.dart';
import '../../../data/repos/login_repo/login_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;
  LoginCubit(this._loginRepo) : super(LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    final resp = await _loginRepo.login(email: email, password: password);
    resp.fold(
      (failure) {
        emit(LoginError(errorMsg: failure.message));
      },
      (loginResponse) {
        emit(LoginSuccess(loginResponse: loginResponse));
      },
    );
  }
}
