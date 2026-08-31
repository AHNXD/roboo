import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';

abstract class QuizzesRepo {
  /// [page] is 1-based; the backend fixes the page size at 25.
  Future<Either<Failure, PagedResult<QuizModel>>> getQuizzes({int page = 1});

  Future<Either<Failure, QuizModel>> getQuizDetails({required int quizId});

  /// [answers] maps a question id to the selected answer id.
  Future<Either<Failure, QuizResultModel>> submitQuiz({
    required int quizId,
    required Map<int, int> answers,
  });
}
