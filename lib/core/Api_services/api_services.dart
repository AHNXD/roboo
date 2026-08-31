import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:roboo/features/auth/presentation/views/login/view/login_screen.dart';
import '../utils/cache_helper.dart';
import '../utils/constats.dart';
import 'auth_interceptor.dart';
import 'urls.dart';

class ApiServices {
  final Dio _dio;

  /// Uploads carry an image, so they get a longer window than an ordinary
  /// request before the app gives up on them.
  static const Duration _uploadSendTimeout = Duration(seconds: 60);

  ApiServices(this._dio) {
    _dio.options.baseUrl = Urls.baseUrl;
    // Dio applies no timeout of its own: without these a stalled request hangs
    // forever behind a spinner with nothing the user can act on. The receive
    // window is deliberately generous — course detail has been observed taking
    // over 13s — so this only trips on a genuinely dead request, and
    // `ErrorHandler` already turns each timeout into a translated message.
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        request: true,
        compact: true,
        maxWidth: 50,
      ),
    );
    _dio.interceptors.add(
      AuthInterceptor(
        onUnauthorized: () {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            LoginScreen.routeName,
            (route) => false,
          );
        },
      ),
    );
  }
  Future<String?> _getStoredToken() async {
    return CacheHelper.getData(key: 'token');
  }

  String _getLatestLanguageCode() {
    final cachedLang = CacheHelper.getData(key: "LOCALE");

    return cachedLang?.toString() ?? 'en';
  }

  Future<Map<String, String>> _headers({bool isMultipart = false}) async {
    final token = await _getStoredToken();

    final String languageCode = _getLatestLanguageCode();

    final Map<String, String> headers = {
      "Accept": 'application/json',
      "Accept-Charset": "application/json",
      "Accept-Language": languageCode,
    };

    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Response> get({required String endPoint}) async {
    return _dio.get(endPoint, options: Options(headers: await _headers()));
  }

  Future<Response> post({
    required String endPoint,
    required dynamic data,
  }) async {
    return _dio.post(
      endPoint,
      data: data,
      options: Options(headers: await _headers()),
    );
  }

  Future<Response> postFormData({
    required String endPoint,
    required FormData data,
  }) async {
    return _dio.post(
      endPoint,
      data: data,
      options: Options(
        headers: await _headers(isMultipart: true),
        sendTimeout: _uploadSendTimeout,
      ),
    );
  }

  Future<Response> put({
    required String endPoint,
    required dynamic data,
  }) async {
    return _dio.put(
      endPoint,
      data: data,
      options: Options(headers: await _headers()),
    );
  }

  Future<Response> delete({required String endPoint}) async {
    return _dio.delete(endPoint, options: Options(headers: await _headers()));
  }
}
