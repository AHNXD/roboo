import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/login_response_model.dart';
import '../../../../../core/utils/google_auth_service.dart';
import '../../../data/repos/login_repo/login_repo.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;
  final GoogleAuthService _googleAuthService;

  LoginCubit(this._loginRepo, this._googleAuthService) : super(LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    final resp = await _loginRepo.login(email: email, password: password);
    resp.fold(
      (failure) {
        emit(LoginError(errorMsg: failure.message));
      },
      (loginResponse) {
        if (loginResponse.mustVerify) {
          final verifiedEmail = loginResponse.user.email;
          emit(
            LoginNeedsVerification(
              email: verifiedEmail?.isNotEmpty == true ? verifiedEmail! : email,
            ),
          );
          return;
        }

        emit(LoginSuccess(loginResponse: loginResponse));
      },
    );
  }

  /// Google account picker first, then the ID token goes to `auth/google`.
  Future<void> loginWithGoogle() async {
    emit(LoginLoading());

    final googleResult = await _googleAuthService.signIn();
    switch (googleResult) {
      case GoogleAuthCancelled():
        // Dismissing the sheet is not a failure; just return to the form.
        emit(LoginInitial());
        return;
      case GoogleAuthFailure(:final messageKey):
        emit(LoginError(errorMsg: messageKey));
        return;
      case GoogleAuthSuccess(:final idToken):
        final resp = await _loginRepo.loginWithGoogle(idToken: idToken);
        resp.fold((failure) => emit(LoginError(errorMsg: failure.message)), (
          loginResponse,
        ) {
          if (loginResponse.mustVerify) {
            final verifiedEmail = loginResponse.user.email;
            emit(LoginNeedsVerification(email: verifiedEmail ?? ''));
            return;
          }

          emit(LoginSuccess(loginResponse: loginResponse));
        });
    }
  }
}
