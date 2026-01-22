import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../features/shared/welcome/view/welcome_screen.dart';
import '../utils/cache_helper.dart';
import '../utils/constats.dart';
import 'auth_interceptor.dart';
import 'urls.dart';

class ApiServices {
  final Dio _dio;
  ApiServices(this._dio) {
    _dio.options.baseUrl = Urls.baseUrl;
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
            WelcomeScreen.routeName,
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

  Future<Map<String, String>> _headers() async {
    final token = await _getStoredToken();

    final String languageCode = _getLatestLanguageCode();

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      "Accept": 'application/json',
      "Accept-Charset": "application/json",
      "Accept-Language": languageCode,
    };

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
