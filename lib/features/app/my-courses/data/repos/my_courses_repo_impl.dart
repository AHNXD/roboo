import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/my_course_model.dart';
import 'my_courses_repo.dart';

class MyCoursesRepoImpl implements MyCoursesRepo {
  final ApiServices _apiServices;

  MyCoursesRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<MyCourseModel>>> getMyCourses() async {
    try {
      final response = await _apiServices.get(endPoint: Urls.myCourses);
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        // Documented as a plain array; a paginated wrapper is tolerated in case
        // the endpoint gains pagination later.
        final coursesData = data is List
            ? data
            : (data is Map<String, dynamic> ? data['data'] : null);

        if (coursesData is List) {
          final courses = coursesData
              .whereType<Map<String, dynamic>>()
              .map(MyCourseModel.fromJson)
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

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
