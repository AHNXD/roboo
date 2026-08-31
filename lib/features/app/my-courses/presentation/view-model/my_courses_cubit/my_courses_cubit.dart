import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/topics/data/models/topic_model.dart';
import '../../../../../shared/topics/data/repos/topics_repo.dart';
import '../../../data/models/my_course_model.dart';
import '../../../data/repos/my_courses_repo.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'my_courses_state.dart';

class MyCoursesCubit extends Cubit<MyCoursesState>
    with SafeEmit<MyCoursesState> {
  final MyCoursesRepo _myCoursesRepo;
  final TopicsRepo _topicsRepo;

  MyCoursesCubit(this._myCoursesRepo, this._topicsRepo)
    : super(const MyCoursesInitial());

  List<MyCourseModel> _allCourses = const [];

  Future<void> getMyCoursesData() async {
    // A refresh keeps whatever topic the student is looking at.
    final previousIndex = switch (state) {
      MyCoursesLoaded(:final selectedIndex) => selectedIndex,
      MyCoursesEmpty(:final selectedIndex) => selectedIndex,
      _ => 0,
    };

    safeEmit(const MyCoursesLoading());

    // Independent requests: fire both, then await.
    final topicsFuture = _topicsRepo.getTopics();
    final coursesFuture = _myCoursesRepo.getMyCourses();

    final topicsResult = await topicsFuture;
    final coursesResult = await coursesFuture;

    final topicsFailure = topicsResult.fold((failure) => failure, (_) => null);
    if (topicsFailure != null) {
      safeEmit(MyCoursesError(errorMsg: topicsFailure.message));
      return;
    }

    final coursesFailure = coursesResult.fold(
      (failure) => failure,
      (_) => null,
    );
    if (coursesFailure != null) {
      safeEmit(MyCoursesError(errorMsg: coursesFailure.message));
      return;
    }

    _allCourses = coursesResult.getOrElse(() => const []);
    _emitFor(
      topics: topicsResult.getOrElse(() => const []),
      selectedIndex: previousIndex,
    );
  }

  /// `my/courses` documents no query parameters, so the topic filter runs on
  /// the already-loaded list.
  void selectTopic(int selectedIndex) {
    final currentState = state;
    final topics = switch (currentState) {
      MyCoursesLoaded(:final topics) => topics,
      MyCoursesEmpty(:final topics) => topics,
      _ => const <TopicModel>[],
    };

    if (topics.isEmpty && selectedIndex != 0) return;

    _emitFor(topics: topics, selectedIndex: selectedIndex);
  }

  void _emitFor({
    required List<TopicModel> topics,
    required int selectedIndex,
  }) {
    final topicId = _topicIdForIndex(
      topics: topics,
      selectedIndex: selectedIndex,
    );
    final courses = topicId == null
        ? _allCourses
        : _allCourses.where((course) => course.topicId == topicId).toList();

    if (courses.isEmpty) {
      safeEmit(MyCoursesEmpty(topics: topics, selectedIndex: selectedIndex));
      return;
    }

    safeEmit(
      MyCoursesLoaded(
        topics: topics,
        courses: courses,
        selectedIndex: selectedIndex,
      ),
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
