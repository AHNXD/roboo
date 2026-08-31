import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/course_favorite_toggle_model.dart';
import '../models/course_model.dart';

abstract class CoursesRepo {
  /// [page] is 1-based; the backend fixes the page size at 25.
  Future<Either<Failure, PagedResult<CourseModel>>> getCourses({
    int? topicId,
    int page = 1,
  });

  /// Public. Up to five courses ranked by how many students bought them,
  /// falling back server-side to a random sample when nothing is purchased.
  Future<Either<Failure, List<CourseModel>>> getFeaturedCourses();

  /// Toggle semantics: sending an already-favorited id removes it.
  Future<Either<Failure, CourseFavoriteToggleModel>> toggleFavorite({
    required int courseId,
  });

  /// The student's favourited courses. Same row shape as `GET courses`, so
  /// every entry already carries `is_favorite: true`.
  Future<Either<Failure, PagedResult<CourseModel>>> getFavoriteCourses({
    int page = 1,
  });
}
