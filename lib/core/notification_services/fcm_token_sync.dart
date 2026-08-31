import '../../features/app/profile/data/repos/profile_repo.dart';
import '../utils/cache_helper.dart';

/// Owns the FCM registration token and getting it to the backend.
///
/// The API accepts `fcm_token` on `auth/register`, `auth/login` and
/// `auth/google` — all of which happen before there is a session — plus,
/// undocumented but verified against the live API, on `auth/profile`, which is
/// the only way to update it mid-session. So:
///
/// * at register/login the token travels inside the auth request itself;
/// * a token that arrives or changes later (permission granted after login,
///   Firebase rotating it, app reinstall) is pushed with `auth/profile`.
class FcmTokenSync {
  static const String tokenKey = 'fcm_token';
  static const String _syncedKey = 'fcm_token_synced';
  static const String _sessionKey = 'token';

  final ProfileRepo _profileRepo;

  FcmTokenSync(this._profileRepo);

  String? get cachedToken {
    final token = CacheHelper.getData(key: tokenKey)?.toString();
    return (token == null || token.isEmpty) ? null : token;
  }

  bool get _isLoggedIn {
    final session = CacheHelper.getData(key: _sessionKey)?.toString();
    return session != null && session.isNotEmpty;
  }

  Future<void> saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    if (token == cachedToken) return;

    await CacheHelper.setString(key: tokenKey, value: token);
  }

  /// Call after login/register succeed: the token went out with that request,
  /// so the backend is already up to date and no extra call is needed.
  Future<void> markSyncedWithAuthRequest(String? token) async {
    if (token == null || token.isEmpty) return;

    await CacheHelper.setString(key: _syncedKey, value: token);
  }

  /// Pushes the token when the backend does not have this one yet. Does nothing
  /// while logged out — the next login carries it instead.
  Future<void> syncIfNeeded() async {
    final token = cachedToken;
    if (token == null || !_isLoggedIn) return;

    final alreadySynced = CacheHelper.getData(key: _syncedKey)?.toString();
    if (alreadySynced == token) return;

    final result = await _profileRepo.updateFcmToken(fcmToken: token);
    if (result.isRight()) {
      await CacheHelper.setString(key: _syncedKey, value: token);
    }
  }

  /// A refreshed token replaces the stored one and is pushed straight away.
  Future<void> onTokenRefreshed(String token) async {
    await saveToken(token);
    await syncIfNeeded();
  }
}
