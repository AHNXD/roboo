import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';

/// Result of asking the user to pick a Google account.
sealed class GoogleAuthResult {
  const GoogleAuthResult();
}

/// The user picked an account and Google issued an ID token for the backend.
class GoogleAuthSuccess extends GoogleAuthResult {
  final String idToken;

  const GoogleAuthSuccess(this.idToken);
}

/// The user dismissed the sheet. Not an error — nothing should be shown.
class GoogleAuthCancelled extends GoogleAuthResult {
  const GoogleAuthCancelled();
}

/// Something went wrong. [messageKey] is a localization key.
class GoogleAuthFailure extends GoogleAuthResult {
  final String messageKey;

  const GoogleAuthFailure(this.messageKey);
}

/// Wraps `google_sign_in` 7.x, whose API is one-shot: `initialize()` once, then
/// `authenticate()` per sign-in.
///
/// The backend wants the Google **ID token** (`POST auth/google` → `token`),
/// not an access token.
class GoogleAuthService {
  /// The web OAuth client id ("client_type": 3 in `google-services.json`).
  ///
  /// Android needs it to mint an ID token whose audience the backend can
  /// verify. Taken from `android/app/google-services.json`; re-check it there
  /// if the Firebase project is ever recreated.
  static const String serverClientId =
      '775735976598-r6j2bgaakkvt4ned9rl4g8f77gkmkdbk.apps.googleusercontent.com';

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    await GoogleSignIn.instance.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    _initialized = true;
  }

  Future<GoogleAuthResult> signIn() async {
    try {
      await _ensureInitialized();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        return const GoogleAuthFailure('google_login_unavailable');
      }

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        // Almost always a missing server client id: Google signed the user in
        // but had no audience to issue an ID token for.
        log('Google sign-in returned no ID token; check serverClientId');
        return const GoogleAuthFailure('google_login_unavailable');
      }

      return GoogleAuthSuccess(idToken);
    } on GoogleSignInException catch (error) {
      log('Google sign-in failed: ${error.code} ${error.description}');

      return switch (error.code) {
        GoogleSignInExceptionCode.canceled => const GoogleAuthCancelled(),
        GoogleSignInExceptionCode.interrupted ||
        GoogleSignInExceptionCode.uiUnavailable => const GoogleAuthFailure(
          'error_tryAgain',
        ),
        GoogleSignInExceptionCode.clientConfigurationError ||
        GoogleSignInExceptionCode.providerConfigurationError =>
          const GoogleAuthFailure('google_login_unavailable'),
        _ => const GoogleAuthFailure('auth.google_login_failed'),
      };
    } catch (error) {
      log('Google sign-in failed: $error');
      return const GoogleAuthFailure('auth.google_login_failed');
    }
  }

  /// Lets the account chooser appear again on the next sign-in.
  Future<void> signOut() async {
    if (!_initialized) return;

    try {
      await GoogleSignIn.instance.signOut();
    } catch (error) {
      log('Google sign-out failed: $error');
    }
  }
}
