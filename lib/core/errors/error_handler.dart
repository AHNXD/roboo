import 'package:dio/dio.dart';
import 'dart:io';
import 'failuer.dart';

class ErrorHandler {
  static const String connectionTimeout = "connectionTimeout";
  static const String sendTimeout = "sendTimeout";
  static const String receiveTimeout = "receiveTimeout";
  static const String cancel = "request_canceled";
  static const String noInternet = "noInternet";
  static const String unknownError = "unknownError";
  static const String badCertificate = "badCertificate";
  static const String connectionError = "connectionError";
  static const String serverError = "serverError";
  static const String notFound = "notFound";
  static const String internalServerError = "internalServerError";
  static const String validationError = "validationError";
  static const String errorTryAgain = "error_tryAgain";

  static String defaultMessage() => errorTryAgain;

  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    if (error is SocketException) {
      return NetworkFailure(noInternet);
    }
    return UnknownFailure(errorTryAgain);
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkFailure(connectionTimeout);
      case DioExceptionType.sendTimeout:
        return NetworkFailure(sendTimeout);
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(receiveTimeout);
      case DioExceptionType.cancel:
        return NetworkFailure(cancel);
      case DioExceptionType.unknown:
        return error.error is SocketException
            ? NetworkFailure(noInternet)
            : UnknownFailure(unknownError);
      case DioExceptionType.badCertificate:
        return NetworkFailure(badCertificate);
      case DioExceptionType.connectionError:
        return NetworkFailure(connectionError);
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
    }
  }

  static Failure _handleResponseError(DioException error) {
    final response = error.response;
    if (response == null) return ServerFailure(serverError);
    switch (response.statusCode) {
      case 400:
      case 401:
      case 403:
        return ServerFailure(response.data['message'] ?? errorTryAgain);
      case 404:
        return ServerFailure(notFound);
      case 422:
        return ValidationFailure(_handleValidationErrors(response.data));
      case 500:
        try {
          return ServerFailure(response.data['message'] ?? internalServerError);
        } catch (e) {
          return ServerFailure(internalServerError);
        }

      case 503:
        return ServerFailure(response.data['message'] ?? serverError);
      default:
        return ServerFailure(serverError);
    }
  }

  static String _handleValidationErrors(dynamic data) {
    final errors = (data is Map<String, dynamic>) ? data['message'] : null;
    if (errors is! Map<String, dynamic>) {
      return validationError;
    }

    final messages = errors.values
        .expand((e) {
          if (e is List) return e.map((v) => v.toString());
          return [e.toString()];
        })
        .join(', ');

    return messages.isNotEmpty ? messages : validationError;
  }
}
