import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/course_details_model.dart';
import 'course_repo.dart';

class CourseRepoImpl implements CourseRepo {
  final ApiServices _apiServices;

  CourseRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, CourseDetailsModel>> getCourseDetails({
    required int courseId,
  }) async {
    try {
      final response = await _apiServices.get(
        endPoint: Urls.courseDetails(courseId),
      );
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(CourseDetailsModel.fromJson(data));
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, int?>> applyCoupon({required String code}) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.couponsApply,
        data: {'code': code},
      );
      final responseData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        return right(
          data is Map<String, dynamic> ? _parseInt(data['course_id']) : null,
        );
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> recordReserveClick({
    required int courseId,
    required String deviceId,
  }) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.courseReserveClick(courseId),
        data: {'device_id': deviceId},
      );
      final responseData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        return right(unit);
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> markLessonWatched({
    required int courseId,
    required int lessonId,
  }) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.courseMarkWatched(courseId),
        data: {'lesson_id': lessonId},
      );
      final responseData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        return right(unit);
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
