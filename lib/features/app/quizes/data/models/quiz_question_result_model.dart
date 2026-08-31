/// One row of `question_results` from `POST quizzes/{id}/submit` — the server's
/// verdict on a single question, delivered only after the quiz is submitted.
class QuizQuestionResultModel {
  final int? questionId;
  final int? selectedAnswerId;
  final bool isCorrect;
  final int? correctAnswerId;

  const QuizQuestionResultModel({
    this.questionId,
    this.selectedAnswerId,
    required this.isCorrect,
    this.correctAnswerId,
  });

  factory QuizQuestionResultModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionResultModel(
      questionId: _parseInt(json['question_id']),
      selectedAnswerId: _parseInt(json['selected_answer_id']),
      isCorrect: _parseBool(json['is_correct']),
      correctAnswerId: _parseInt(json['correct_answer_id']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalizedValue = value?.toString().toLowerCase();
    return normalizedValue == 'true' || normalizedValue == '1';
  }
}
