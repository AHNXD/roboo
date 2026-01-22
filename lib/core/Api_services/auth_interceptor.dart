import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final void Function() onUnauthorized;

  AuthInterceptor({required this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized();

      final dummyResponse = Response(
        requestOptions: err.requestOptions,
        statusCode: 401,
        data: {'message': 'Unauthorized'},
      );
      handler.resolve(dummyResponse);
    } else {
      super.onError(err, handler);
    }
  }
}
