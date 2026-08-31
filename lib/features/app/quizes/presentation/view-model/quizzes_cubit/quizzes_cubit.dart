import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../shared/topics/data/models/topic_model.dart';
import '../../../../../shared/topics/data/repos/topics_repo.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repos/quizzes_repo.dart';
import '../../../../../../core/errors/failuer.dart';
import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'quizzes_state.dart';

class QuizzesCubit extends Cubit<QuizzesState> with SafeEmit<QuizzesState> {
  final QuizzesRepo _quizzesRepo;
  final TopicsRepo _topicsRepo;

  QuizzesCubit(this._quizzesRepo, this._topicsRepo)
    : super(const QuizzesInitial());

  /// The topic tabs filter this list on the client — `GET quizzes` documents no
  /// topic parameter — so a tab can only be correct if every quiz is loaded.
  /// Paging the screen instead would silently show a partial topic, so all
  /// pages are fetched up front. The cap stops a runaway loop if the backend
  /// ever reports `last_page` wrongly.
  static const int _maxPages = 20;

  List<QuizModel> _allQuizzes = const [];

  Future<void> getQuizzesData() async {
    // A refresh keeps whatever topic the student is looking at.
    final previousIndex = switch (state) {
      QuizzesLoaded(:final selectedIndex) => selectedIndex,
      QuizzesEmpty(:final selectedIndex) => selectedIndex,
      _ => 0,
    };

    safeEmit(const QuizzesLoading());

    final topicsResult = await _topicsRepo.getTopics();
    final topicsFailure = topicsResult.fold((failure) => failure, (_) => null);
    if (topicsFailure != null) {
      safeEmit(QuizzesError(errorMsg: topicsFailure.message));
      return;
    }

    final quizzesResult = await _fetchAllQuizzes();
    final quizzesFailure = quizzesResult.fold(
      (failure) => failure,
      (_) => null,
    );
    if (quizzesFailure != null) {
      safeEmit(QuizzesError(errorMsg: quizzesFailure.message));
      return;
    }

    final topics = topicsResult.getOrElse(() => const []);
    _allQuizzes = quizzesResult.getOrElse(() => const []);

    _emitQuizzesFor(topics: topics, selectedIndex: previousIndex);
  }

  /// Walks every page of `GET quizzes`. Each page is 25; the total is small
  /// enough that this is one request today, and it keeps client-side topic
  /// filtering honest as the list grows.
  Future<Either<Failure, List<QuizModel>>> _fetchAllQuizzes() async {
    final all = <QuizModel>[];
    var page = 1;

    while (page <= _maxPages) {
      final result = await _quizzesRepo.getQuizzes(page: page);

      final failure = result.fold((failure) => failure, (_) => null);
      if (failure != null) return left(failure);

      final pageResult = result.getOrElse(
        () => const PagedResult(items: [], pagination: PaginationModel.single),
      );
      all.addAll(pageResult.items);

      if (!pageResult.hasMore) break;
      page = pageResult.nextPage;
    }

    return right(all);
  }

  /// `GET quizzes` documents no topic filter, so filtering stays on the client
  /// over the fully-loaded list instead of guessing a query parameter.
  void selectTopic(int selectedIndex) {
    final currentState = state;
    final topics = switch (currentState) {
      QuizzesLoaded(:final topics) => topics,
      QuizzesEmpty(:final topics) => topics,
      _ => const <TopicModel>[],
    };

    if (topics.isEmpty && selectedIndex != 0) return;

    _emitQuizzesFor(topics: topics, selectedIndex: selectedIndex);
  }

  void _emitQuizzesFor({
    required List<TopicModel> topics,
    required int selectedIndex,
  }) {
    final topicId = _topicIdForIndex(
      topics: topics,
      selectedIndex: selectedIndex,
    );
    final quizzes = topicId == null
        ? _allQuizzes
        : _allQuizzes.where((quiz) => quiz.topicId == topicId).toList();

    if (quizzes.isEmpty) {
      safeEmit(QuizzesEmpty(topics: topics, selectedIndex: selectedIndex));
      return;
    }

    safeEmit(
      QuizzesLoaded(
        topics: topics,
        quizzes: quizzes,
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
