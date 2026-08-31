import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../courses/data/models/course_model.dart';
import '../../../../courses/data/repos/courses_repo.dart';
import '../../../../my-courses/data/models/my_course_model.dart';
import '../../../../my-courses/data/repos/my_courses_repo.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'home_state.dart';

/// Home has no endpoint of its own; it composes the already-integrated feature
/// repositories.
class HomeCubit extends Cubit<HomeState> with SafeEmit<HomeState> {
  final CoursesRepo _coursesRepo;
  final MyCoursesRepo _myCoursesRepo;

  HomeCubit(this._coursesRepo, this._myCoursesRepo)
    : super(const HomeInitial());

  /// How many courses each home preview shows before "view all".
  static const int previewCount = 3;

  Future<void> getHomeData() async {
    safeEmit(const HomeLoading());

    // Independent requests: fire both, then await.
    final featuredFuture = _coursesRepo.getFeaturedCourses();
    final myCoursesFuture = _myCoursesRepo.getMyCourses();

    final featuredResult = await featuredFuture;
    final myCoursesResult = await myCoursesFuture;

    final featured = featuredResult.fold((failure) {
      safeEmit(HomeError(errorMsg: failure.message));
      return null;
    }, (courses) => courses);
    if (featured == null) return;

    // The student's own courses are a bonus row: a failure there (not logged
    // in, for instance) must not take the whole home screen down.
    final myCourses = myCoursesResult.getOrElse(() => const []);

    if (featured.isEmpty && myCourses.isEmpty) {
      safeEmit(const HomeEmpty());
      return;
    }

    safeEmit(
      HomeLoaded(
        courses: featured.take(previewCount).toList(),
        myCourses: myCourses.take(previewCount).toList(),
      ),
    );
  }
}
