import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/error_handler.dart';
import '../../../../profile/data/repos/profile_repo.dart';
import '../../../data/models/quiz_result_model.dart';
import '../../../data/repos/quizzes_repo.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'quiz_result_state.dart';

class QuizResultCubit extends Cubit<QuizResultState>
    with SafeEmit<QuizResultState> {
  final QuizzesRepo _quizzesRepo;
  final ProfileRepo _profileRepo;

  QuizResultCubit(this._quizzesRepo, this._profileRepo)
    : super(const QuizResultInitial());

  Future<void> submitQuiz({
    required int? quizId,
    required Map<int, int> answers,
  }) async {
    if (quizId == null || answers.isEmpty) {
      safeEmit(QuizResultError(errorMsg: ErrorHandler.defaultMessage()));
      return;
    }

    safeEmit(const QuizResultLoading());

    final result = await _quizzesRepo.submitQuiz(
      quizId: quizId,
      answers: answers,
    );
    result.fold(
      (failure) => safeEmit(QuizResultError(errorMsg: failure.message)),
      (quizResult) {
        safeEmit(QuizResultLoaded(result: quizResult));

        // Points were just awarded, and the header reads them from the cached
        // user — refresh it so the new total shows without a re-login. A
        // refused attempt awards nothing, so it is not worth a request.
        if (!quizResult.isRejected && quizResult.pointsEarned > 0) {
          unawaited(_profileRepo.getProfile());
        }
      },
    );
  }
}
