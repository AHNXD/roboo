import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/quiz_model.dart';
import '../models/quiz_result_model.dart';
import 'quizzes_repo.dart';

class QuizzesRepoImpl implements QuizzesRepo {
  final ApiServices _apiServices;

  QuizzesRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, PagedResult<QuizModel>>> getQuizzes({
    int page = 1,
  }) async {
    try {
      final response = await _apiServices.get(
        endPoint: pagedEndpoint(Urls.quizzes, page),
      );
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        final quizzesData = data is Map<String, dynamic>
            ? data['quizzes']
            : null;

        if (quizzesData is List) {
          final quizzes = quizzesData
              .whereType<Map<String, dynamic>>()
              .map(QuizModel.fromJson)
              .toList();
          return right(
            PagedResult(
              items: quizzes,
              pagination: PaginationModel.fromJson(
                data is Map<String, dynamic> &&
                        data['pagination'] is Map<String, dynamic>
                    ? data['pagination'] as Map<String, dynamic>
                    : null,
              ),
            ),
          );
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, QuizModel>> getQuizDetails({
    required int quizId,
  }) async {
    try {
      final response = await _apiServices.get(
        endPoint: Urls.quizDetails(quizId),
      );
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(QuizModel.fromJson(data));
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, QuizResultModel>> submitQuiz({
    required int quizId,
    required Map<int, int> answers,
  }) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.quizSubmit(quizId),
        data: {
          // The backend expects { "answers": { "<question_id>": answer_id } }.
          'answers': answers.map(
            (questionId, answerId) => MapEntry('$questionId', answerId),
          ),
        },
      );
      final responseData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(QuizResultModel.fromJson(data));
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
