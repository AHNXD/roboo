import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/error_handler.dart';
import '../../../../../../core/utils/device_id_provider.dart';
import '../../../data/models/course_details_model.dart';
import '../../../data/repos/course_repo.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState>
    with SafeEmit<CourseDetailsState> {
  final CourseRepo _courseRepo;

  CourseDetailsCubit(this._courseRepo) : super(const CourseDetailsInitial());

  int? _courseId;

  Future<void> getCourseDetails(int? courseId) async {
    if (courseId == null) {
      safeEmit(CourseDetailsError(errorMsg: ErrorHandler.defaultMessage()));
      return;
    }

    _courseId = courseId;
    safeEmit(const CourseDetailsLoading());

    final result = await _courseRepo.getCourseDetails(courseId: courseId);
    result.fold(
      (failure) => safeEmit(CourseDetailsError(errorMsg: failure.message)),
      (course) => safeEmit(CourseDetailsLoaded(course: course)),
    );
  }

  /// Unlocks the course with a physical coupon code. On success the details are
  /// re-fetched so `is_unlocked` and the lesson list come from the server
  /// rather than being assumed locally.
  Future<void> applyCoupon(String code) async {
    final currentState = state;
    if (currentState is! CourseDetailsLoaded) return;

    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) return;

    safeEmit(
      CourseDetailsLoaded(course: currentState.course, isUnlocking: true),
    );

    final result = await _courseRepo.applyCoupon(code: trimmedCode);
    await result.fold(
      (failure) async {
        safeEmit(CourseDetailsActionError(errorMsg: failure.message));
        safeEmit(CourseDetailsLoaded(course: currentState.course));
      },
      (unlockedCourseId) async {
        safeEmit(const CourseDetailsCouponApplied());
        await getCourseDetails(unlockedCourseId ?? _courseId);
      },
    );
  }

  /// Fire-and-forget lead tracking: the collection describes it as marketing
  /// follow-up, so a failure must not block the booking flow the user asked
  /// for. Nothing is emitted either way.
  Future<void> recordReserveClick() async {
    final courseId = _courseId;
    if (courseId == null) return;

    final deviceId = await DeviceIdProvider.get();
    await _courseRepo.recordReserveClick(
      courseId: courseId,
      deviceId: deviceId,
    );
  }
}
