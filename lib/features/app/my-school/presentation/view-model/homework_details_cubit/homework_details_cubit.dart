import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/error_handler.dart';
import '../../../data/models/homework_model.dart';
import '../../../data/repos/homework_repo.dart';
import '../../../../../../core/utils/safe_emit.dart';

part 'homework_details_state.dart';

class HomeworkDetailsCubit extends Cubit<HomeworkDetailsState>
    with SafeEmit<HomeworkDetailsState> {
  final HomeworkRepo _homeworkRepo;

  HomeworkDetailsCubit(this._homeworkRepo)
    : super(const HomeworkDetailsInitial());

  int? _homeworkId;
  HomeworkModel? _homework;

  /// question id -> chosen option id
  final Map<int, int> _answers = {};

  Future<void> getHomeworkDetails(int? homeworkId) async {
    if (homeworkId == null) {
      safeEmit(HomeworkDetailsError(errorMsg: ErrorHandler.defaultMessage()));
      return;
    }

    _homeworkId = homeworkId;
    safeEmit(const HomeworkDetailsLoading());

    final result = await _homeworkRepo.getHomeworkDetails(
      homeworkId: homeworkId,
    );
    result.fold(
      (failure) => safeEmit(HomeworkDetailsError(errorMsg: failure.message)),
      (homework) {
        _homework = homework;
        _answers.clear();
        _emitLoaded();
      },
    );
  }

  void selectOption({required int questionId, required int optionId}) {
    if (_homework?.isAnswerable != true) return;

    _answers[questionId] = optionId;
    _emitLoaded();
  }

  Future<void> submitMcq() async {
    final homework = _homework;
    final homeworkId = _homeworkId;
    if (homework == null || homeworkId == null) return;

    // Every question has to be answered before anything is sent; a partial
    // submission cannot be taken back.
    if (_answers.length != homework.questions.length) return;

    await _runSubmit(
      () => _homeworkRepo.submitMcqHomework(
        homeworkId: homeworkId,
        answers: Map<int, int>.from(_answers),
      ),
    );
  }

  /// Text, image, video, and the two combinations. What is required depends on
  /// the homework's type, so the screen only enables the button once it has
  /// what that type needs — this re-checks rather than trusting it.
  Future<void> submitAnswer({String? content, String? filePath}) async {
    final homework = _homework;
    final homeworkId = _homeworkId;
    if (homework == null || homeworkId == null) return;

    final trimmedContent = content?.trim() ?? '';
    if (homework.type.needsText && trimmedContent.isEmpty) return;
    if (homework.type.needsFile && (filePath == null || filePath.isEmpty)) {
      return;
    }

    await _runSubmit(
      () => _homeworkRepo.submitHomework(
        homeworkId: homeworkId,
        content: trimmedContent.isEmpty ? null : trimmedContent,
        filePath: filePath,
      ),
    );
  }

  Future<void> _runSubmit(Future<dynamic> Function() submit) async {
    _emitLoaded(isSubmitting: true);

    final result = await submit();
    await result.fold(
      (failure) async {
        safeEmit(HomeworkSubmitError(errorMsg: failure.message));
        _emitLoaded();
      },
      (_) async {
        safeEmit(const HomeworkSubmitSuccess());
        // Re-fetch so the status, score and feedback come from the server.
        await getHomeworkDetails(_homeworkId);
      },
    );
  }

  void _emitLoaded({bool isSubmitting = false}) {
    final homework = _homework;
    if (homework == null) return;

    safeEmit(
      HomeworkDetailsLoaded(
        homework: homework,
        selectedAnswers: Map<int, int>.unmodifiable(_answers),
        isSubmitting: isSubmitting,
      ),
    );
  }
}
