import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/topics/data/models/topic_model.dart';
import '../../../../../shared/topics/data/repos/topics_repo.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repos/courses_repo.dart';
import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> with SafeEmit<CoursesState> {
  final CoursesRepo _coursesRepo;
  final TopicsRepo _topicsRepo;

  CoursesCubit(this._coursesRepo, this._topicsRepo) : super(CoursesInitial());

  List<TopicModel> _topics = const [];
  List<CourseModel> _courses = const [];
  int _selectedIndex = 0;
  PaginationModel _pagination = PaginationModel.single;
  bool _isLoadingMore = false;

  /// Set when a topic was requested before the topic list arrived — the home
  /// screen can ask for one while this tab has never been opened.
  String? _pendingSlug;

  Future<void> getCoursesData() async {
    safeEmit(CoursesLoading());

    // Independent requests: fire both, then await, so the screen waits for the
    // slower one rather than for their sum.
    final topicsFuture = _topicsRepo.getTopics();
    final coursesFuture = _coursesRepo.getCourses();

    final topicsResult = await topicsFuture;
    final coursesResult = await coursesFuture;

    final topicsFailure = topicsResult.fold((failure) => failure, (_) => null);
    if (topicsFailure != null) {
      safeEmit(CoursesError(errorMsg: topicsFailure.message));
      return;
    }

    final coursesFailure = coursesResult.fold(
      (failure) => failure,
      (_) => null,
    );
    if (coursesFailure != null) {
      safeEmit(CoursesError(errorMsg: coursesFailure.message));
      return;
    }

    _topics = topicsResult.getOrElse(() => const []);
    final page = coursesResult.getOrElse(
      () => const PagedResult(items: [], pagination: PaginationModel.single),
    );
    _courses = page.items;
    _pagination = page.pagination;
    _selectedIndex = 0;

    if (_courses.isEmpty) {
      safeEmit(CoursesEmpty(topics: _topics));
      await _applyPendingSlug();
      return;
    }

    safeEmit(
      CoursesLoaded(topics: _topics, courses: _courses, hasMore: page.hasMore),
    );

    await _applyPendingSlug();
  }

  /// Selects a topic by its `slug` rather than its index, so the caller does not
  /// need to know the order the API returned topics in — or their ids, which
  /// differ between environments. An unknown slug is ignored.
  Future<void> selectTopicBySlug(String slug) async {
    if (_topics.isEmpty) {
      // Asked for before the topics arrived; applied as soon as they do.
      _pendingSlug = slug;
      return;
    }

    final index = _topics.indexWhere((topic) => topic.slug == slug);
    if (index == -1) return;

    // The chip row carries an "all" entry in front of the topics.
    await selectTopic(index + 1);
  }

  Future<void> _applyPendingSlug() async {
    final pending = _pendingSlug;
    if (pending == null) return;

    _pendingSlug = null;
    await selectTopicBySlug(pending);
  }

  /// Appends the next page. A failure here leaves the courses already on screen
  /// untouched; scrolling again retries.
  Future<void> loadMoreCourses() async {
    if (_isLoadingMore || !_pagination.hasMore) return;

    _isLoadingMore = true;
    safeEmit(
      CoursesLoaded(
        topics: _topics,
        courses: _courses,
        selectedIndex: _selectedIndex,
        hasMore: true,
        isLoadingMore: true,
      ),
    );

    final result = await _coursesRepo.getCourses(
      topicId: _topicIdForIndex(topics: _topics, selectedIndex: _selectedIndex),
      page: _pagination.nextPage,
    );

    _isLoadingMore = false;

    result.fold(
      (_) => safeEmit(
        CoursesLoaded(
          topics: _topics,
          courses: _courses,
          selectedIndex: _selectedIndex,
          hasMore: _pagination.hasMore,
        ),
      ),
      (page) {
        _courses = [..._courses, ...page.items];
        _pagination = page.pagination;
        safeEmit(
          CoursesLoaded(
            topics: _topics,
            courses: _courses,
            selectedIndex: _selectedIndex,
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }

  Future<void> selectTopic(int selectedIndex) async {
    final currentState = state;
    if (currentState is! CoursesLoaded &&
        currentState is! CoursesEmpty &&
        currentState is! CoursesContentLoading &&
        currentState is! CoursesContentError) {
      return;
    }

    final topics = switch (currentState) {
      CoursesLoaded(:final topics) => topics,
      CoursesEmpty(:final topics) => topics,
      CoursesContentLoading(:final topics) => topics,
      CoursesContentError(:final topics) => topics,
      _ => const <TopicModel>[],
    };

    final topicId = _topicIdForIndex(
      topics: topics,
      selectedIndex: selectedIndex,
    );
    if (selectedIndex != 0 && topicId == null) return;

    safeEmit(
      CoursesContentLoading(topics: topics, selectedIndex: selectedIndex),
    );

    // Switching topic starts a new list, so page 1 replaces rather than appends.
    _topics = topics;
    _selectedIndex = selectedIndex;

    final result = await _coursesRepo.getCourses(topicId: topicId);
    result.fold(
      (failure) => safeEmit(
        CoursesContentError(
          topics: topics,
          selectedIndex: selectedIndex,
          errorMsg: failure.message,
        ),
      ),
      (page) {
        _courses = page.items;
        _pagination = page.pagination;

        if (_courses.isEmpty) {
          safeEmit(CoursesEmpty(topics: topics, selectedIndex: selectedIndex));
          return;
        }

        safeEmit(
          CoursesLoaded(
            topics: topics,
            courses: _courses,
            selectedIndex: selectedIndex,
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }

  int? _topicIdForIndex({
    required List<TopicModel> topics,
    required int selectedIndex,
  }) {
    if (selectedIndex == 0) return null;

    final topicIndex = selectedIndex - 1;
    if (topicIndex < 0 || topicIndex >= topics.length) return null;

    return topics[topicIndex].id;
  }
}
