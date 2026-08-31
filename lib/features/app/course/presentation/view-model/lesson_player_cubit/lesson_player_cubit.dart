import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/safe_emit.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repos/course_repo.dart';

part 'lesson_player_state.dart';

/// Owns which lesson is playing and reports finished lessons to the backend.
class LessonPlayerCubit extends Cubit<LessonPlayerState>
    with SafeEmit<LessonPlayerState> {
  final CourseRepo _courseRepo;
  final int courseId;

  LessonPlayerCubit({
    required CourseRepo courseRepo,
    required this.courseId,
    required List<LessonModel> lessons,
    required int initialIndex,
  }) : _courseRepo = courseRepo,
       super(
         LessonPlayerState(
           lessons: lessons,
           currentIndex: initialIndex.clamp(
             0,
             lessons.isEmpty ? 0 : lessons.length - 1,
           ),
         ),
       );

  void selectLesson(int index) {
    if (index < 0 || index >= state.lessons.length) return;
    if (index == state.currentIndex) return;
    safeEmit(state.copyWith(currentIndex: index));
  }

  void playNext() => selectLesson(state.currentIndex + 1);

  bool isWatched(LessonModel lesson) {
    final id = lesson.id;
    return lesson.isWatched ||
        (id != null && state.watchedLessonIds.contains(id));
  }

  /// Guards the refresh below: one attempt per failure, so a stream that is
  /// genuinely broken cannot spin the screen in a refetch loop.
  bool _isRefreshingUrls = false;
  int? _lastRefreshedLessonId;

  /// Re-fetches the course to replace expired video urls. They are signed for
  /// two hours from when the response was built, so a player opened long after
  /// the course was loaded fails until the urls are renewed.
  Future<void> refreshExpiredUrls() async {
    final lessonId = state.currentLesson?.id;
    if (_lastRefreshedLessonId == lessonId) return;

    _lastRefreshedLessonId = lessonId;
    await _reloadLessons();
  }

  /// Called when the student returns from a lesson quiz. `solved` is computed
  /// server-side and travels with the lesson, so without this the quiz card
  /// still says "open" and lets them back into a quiz they just finished.
  /// Unguarded, unlike the url refresh: finishing a quiz really did change the
  /// data, every time.
  Future<void> reloadAfterQuiz() => _reloadLessons();

  Future<void> _reloadLessons() async {
    if (_isRefreshingUrls) return;
    _isRefreshingUrls = true;

    final result = await _courseRepo.getCourseDetails(courseId: courseId);
    _isRefreshingUrls = false;

    result.fold((_) {}, (course) {
      if (course.lessons.isEmpty) return;

      // Keep the student on the same lesson; only the urls should change.
      final refreshed = [
        for (final lesson in state.lessons)
          course.lessons.firstWhere(
            (fresh) => fresh.id == lesson.id,
            orElse: () => lesson,
          ),
      ];

      safeEmit(state.copyWith(lessons: refreshed));
    });
  }

  void clearActionError() {
    if (state.actionErrorMsg == null) return;
    safeEmit(state.copyWith(clearActionError: true));
  }

  /// Called both by the "mark as watched" button and automatically when
  /// playback reaches the end. The endpoint is idempotent — re-sending keeps
  /// the lesson watched rather than toggling it off — so a duplicate call is
  /// harmless, but it is skipped anyway.
  Future<void> markCurrentWatched() async {
    final lesson = state.currentLesson;
    final lessonId = lesson?.id;
    if (lesson == null || lessonId == null) return;
    if (isWatched(lesson) || state.isMarkingWatched) return;

    // Optimistic: the tick appears at once, and is taken back if the request
    // fails, so the screen never claims progress the server did not record.
    safeEmit(
      state.copyWith(
        watchedLessonIds: {...state.watchedLessonIds, lessonId},
        isMarkingWatched: true,
        clearActionError: true,
      ),
    );

    final result = await _courseRepo.markLessonWatched(
      courseId: courseId,
      lessonId: lessonId,
    );

    result.fold(
      (failure) => safeEmit(
        state.copyWith(
          watchedLessonIds: {...state.watchedLessonIds}..remove(lessonId),
          isMarkingWatched: false,
          actionErrorMsg: failure.message,
        ),
      ),
      (_) => safeEmit(state.copyWith(isMarkingWatched: false)),
    );
  }
}
