import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/course_details_model.dart';

abstract class CourseRepo {
  Future<Either<Failure, CourseDetailsModel>> getCourseDetails({
    required int courseId,
  });

  /// Returns the id of the course the coupon unlocked.
  Future<Either<Failure, int?>> applyCoupon({required String code});

  /// Marketing/lead tracking for the reserve button.
  Future<Either<Failure, Unit>> recordReserveClick({
    required int courseId,
    required String deviceId,
  });

  /// Records that the student finished a lesson. This is the write half of the
  /// `progress` figure the course cards read.
  Future<Either<Failure, Unit>> markLessonWatched({
    required int courseId,
    required int lessonId,
  });
}
