import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/my_course_model.dart';

abstract class MyCoursesRepo {
  Future<Either<Failure, List<MyCourseModel>>> getMyCourses();
}
