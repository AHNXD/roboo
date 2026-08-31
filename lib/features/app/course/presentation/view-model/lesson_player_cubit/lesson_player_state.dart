part of 'lesson_player_cubit.dart';

final class LessonPlayerState extends Equatable {
  final List<LessonModel> lessons;
  final int currentIndex;

  /// Lessons marked watched during this session, on top of whatever the server
  /// already had. Kept separately so the list reflects progress immediately
  /// without re-fetching the course.
  final Set<int> watchedLessonIds;

  final bool isMarkingWatched;

  /// Transient: shown once, then cleared with `clearActionError`.
  final String? actionErrorMsg;

  const LessonPlayerState({
    required this.lessons,
    required this.currentIndex,
    this.watchedLessonIds = const {},
    this.isMarkingWatched = false,
    this.actionErrorMsg,
  });

  LessonModel? get currentLesson =>
      currentIndex >= 0 && currentIndex < lessons.length
      ? lessons[currentIndex]
      : null;

  LessonModel? get nextLesson =>
      currentIndex + 1 < lessons.length ? lessons[currentIndex + 1] : null;

  bool get hasMarkedAnyWatched => watchedLessonIds.isNotEmpty;

  LessonPlayerState copyWith({
    List<LessonModel>? lessons,
    int? currentIndex,
    Set<int>? watchedLessonIds,
    bool? isMarkingWatched,
    String? actionErrorMsg,
    bool clearActionError = false,
  }) {
    return LessonPlayerState(
      lessons: lessons ?? this.lessons,
      currentIndex: currentIndex ?? this.currentIndex,
      watchedLessonIds: watchedLessonIds ?? this.watchedLessonIds,
      isMarkingWatched: isMarkingWatched ?? this.isMarkingWatched,
      actionErrorMsg: clearActionError
          ? null
          : (actionErrorMsg ?? this.actionErrorMsg),
    );
  }

  @override
  List<Object?> get props => [
    lessons,
    currentIndex,
    watchedLessonIds,
    isMarkingWatched,
    actionErrorMsg,
  ];
}
