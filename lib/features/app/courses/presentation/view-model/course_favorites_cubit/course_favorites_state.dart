part of 'course_favorites_cubit.dart';

class CourseFavoritesState extends Equatable {
  /// The favourites list, loaded on demand by the favourites screen.
  final List<CourseModel> courses;
  final bool isLoadingList;
  final String? listErrorMsg;

  /// course id -> favorite, for toggles made in this session.
  final Map<int, bool> overrides;

  /// The course whose toggle is in flight, if any.
  final int? pendingCourseId;

  final String? errorMsg;

  /// Which course the error belongs to, so one failed toggle does not make
  /// every heart on screen complain.
  final int? errorCourseId;

  /// Another page of favourites exists on the server.
  final bool hasMore;

  /// That next page is being fetched right now.
  final bool isLoadingMore;

  const CourseFavoritesState({
    this.courses = const [],
    this.isLoadingList = false,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.listErrorMsg,
    this.overrides = const {},
    this.pendingCourseId,
    this.errorMsg,
    this.errorCourseId,
  });

  /// [fallback] is the `is_favorite` the API sent with the course.
  bool isFavorite(int? courseId, {bool fallback = false}) {
    if (courseId == null) return false;

    return overrides[courseId] ?? fallback;
  }

  bool isPending(int? courseId) =>
      courseId != null && pendingCourseId == courseId;

  CourseFavoritesState copyWith({
    List<CourseModel>? courses,
    bool? isLoadingList,
    bool? hasMore,
    bool? isLoadingMore,
    String? listErrorMsg,
    bool clearListError = false,
    Map<int, bool>? overrides,
    int? pendingCourseId,
    String? errorMsg,
    int? errorCourseId,
    bool clearPending = false,
    bool clearError = false,
  }) {
    return CourseFavoritesState(
      courses: courses ?? this.courses,
      isLoadingList: isLoadingList ?? this.isLoadingList,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      listErrorMsg: clearListError ? null : (listErrorMsg ?? this.listErrorMsg),
      overrides: overrides ?? this.overrides,
      pendingCourseId: clearPending
          ? null
          : (pendingCourseId ?? this.pendingCourseId),
      errorMsg: clearError ? null : (errorMsg ?? this.errorMsg),
      errorCourseId: clearError ? null : (errorCourseId ?? this.errorCourseId),
    );
  }

  @override
  List<Object?> get props => [
    courses,
    isLoadingList,
    hasMore,
    isLoadingMore,
    listErrorMsg,
    overrides.entries.map((e) => '${e.key}:${e.value}').toList(),
    pendingCourseId,
    errorMsg,
    errorCourseId,
  ];
}
