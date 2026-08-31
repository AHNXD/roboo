import 'enrollment_model.dart' show localizedInt;

/// One row of a submission's `question_results`. The backend withholds the whole
/// array (sends `null`) until the teacher releases the mark, so an empty list
/// means "not released yet", never "all wrong".
///
/// Note the field names differ from the quiz equivalent: homework says
/// `*_option_id`, quizzes say `*_answer_id`.
class HomeworkQuestionResultModel {
  final int? questionId;
  final int? selectedOptionId;
  final bool isCorrect;
  final int? correctOptionId;

  const HomeworkQuestionResultModel({
    this.questionId,
    this.selectedOptionId,
    required this.isCorrect,
    this.correctOptionId,
  });

  factory HomeworkQuestionResultModel.fromJson(Map<String, dynamic> json) {
    return HomeworkQuestionResultModel(
      questionId: localizedInt(json['question_id']),
      selectedOptionId: localizedInt(json['selected_option_id']),
      isCorrect: json['is_correct'] == true,
      correctOptionId: localizedInt(json['correct_option_id']),
    );
  }
}
