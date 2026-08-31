import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/course_favorite_toggle_model.dart';
import '../models/course_model.dart';
import 'courses_repo.dart';

class CoursesRepoImpl implements CoursesRepo {
  final ApiServices _apiServices;

  CoursesRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, PagedResult<CourseModel>>> getCourses({
    int? topicId,
    int page = 1,
  }) async {
    try {
      final response = await _apiServices.get(
        endPoint: _coursesEndpointWithFilters(topicId: topicId, page: page),
      );
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        final coursesData = data is Map<String, dynamic>
            ? data['courses']
            : null;

        if (coursesData is List) {
          final courses = coursesData
              .whereType<Map<String, dynamic>>()
              .map(CourseModel.fromJson)
              .toList();

          return right(
            PagedResult(
              items: courses,
              // Named-array shape: paging sits in its own `pagination` object.
              pagination: PaginationModel.fromJson(
                data is Map<String, dynamic> &&
                        data['pagination'] is Map<String, dynamic>
                    ? data['pagination'] as Map<String, dynamic>
                    : null,
              ),
            ),
          );
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, List<CourseModel>>> getFeaturedCourses() async {
    try {
      final response = await _apiServices.get(endPoint: Urls.coursesFeatured);
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        // Documented as a plain array; the named-array shape the other course
        // endpoints use is accepted too.
        final coursesData = data is List
            ? data
            : (data is Map<String, dynamic> ? data['courses'] : null);

        if (coursesData is List) {
          final courses = coursesData
              .whereType<Map<String, dynamic>>()
              .map(CourseModel.fromJson)
              .toList();
          return right(courses);
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, CourseFavoriteToggleModel>> toggleFavorite({
    required int courseId,
  }) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.coursesFavorite,
        data: {
          'course_ids': [courseId],
        },
      );
      final responseData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(CourseFavoriteToggleModel.fromJson(data));
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, PagedResult<CourseModel>>> getFavoriteCourses({
    int page = 1,
  }) async {
    try {
      final response = await _apiServices.get(
        endPoint: pagedEndpoint(Urls.coursesFavorites, page),
      );
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        // Verified live: this one answers `{courses, pagination}`, unlike
        // `courses/featured` which is a plain array.
        final coursesData = data is Map<String, dynamic>
            ? data['courses']
            : (data is List ? data : null);

        if (coursesData is List) {
          final courses = coursesData
              .whereType<Map<String, dynamic>>()
              .map(CourseModel.fromJson)
              .toList();
          return right(
            PagedResult(
              items: courses,
              pagination: PaginationModel.fromJson(
                data is Map<String, dynamic> &&
                        data['pagination'] is Map<String, dynamic>
                    ? data['pagination'] as Map<String, dynamic>
                    : null,
              ),
            ),
          );
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  String _coursesEndpointWithFilters({int? topicId, int page = 1}) {
    final query = <String, String>{
      if (page > 1) 'page': page.toString(),
      if (topicId != null) 'topic_id': topicId.toString(),
    };

    if (query.isEmpty) return Urls.courses;

    return Uri(path: Urls.courses, queryParameters: query).toString();
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
