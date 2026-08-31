import 'quiz_question_result_model.dart';

class QuizResultModel {
  final bool isSuccess;
  final int score;
  final int total;
  final int pointsEarned;
  final bool isPerfect;

  /// Since 30 Aug 2026 this means "has attempted this at least once, so no
  /// more points are available" — not "passed". It is true from the first
  /// submission onward, including a zero-score one.
  final bool solved;

  /// Set when the server refused the attempt. Course and lesson quizzes allow
  /// one attempt ever, and a second one comes back HTTP 200 with the refusal
  /// in the inner envelope, so this is the only thing that distinguishes it.
  final String? message;

  /// Per-question verdict. Added to the contract on 2026-08-26 and possibly not
  /// deployed yet, so an absent list is normal, not an error.
  final List<QuizQuestionResultModel> questionResults;

  const QuizResultModel({
    required this.isSuccess,
    required this.score,
    required this.total,
    required this.pointsEarned,
    required this.isPerfect,
    this.solved = false,
    this.message,
    this.questionResults = const [],
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    final questionResults = json['question_results'];

    return QuizResultModel(
      isSuccess: _parseBool(json['success']),
      score: _parseInt(json['score']) ?? 0,
      total: _parseInt(json['total']) ?? 0,
      pointsEarned: _parseInt(json['points_earned']) ?? 0,
      isPerfect: _parseBool(json['is_perfect']),
      solved: _parseBool(json['solved']),
      message: json['message']?.toString(),
      questionResults: questionResults is List
          ? questionResults
                .whereType<Map<String, dynamic>>()
                .map(QuizQuestionResultModel.fromJson)
                .toList()
          : const [],
    );
  }

  /// No pass mark exists in the API, so half the questions is the app's rule.
  /// Change it here if the product defines one.
  bool get isPassed {
    if (total <= 0) return isPerfect;
    return score * 2 >= total;
  }

  /// The attempt was refused rather than graded — there is no score to show.
  /// The outer HTTP status is 200 either way, so this is the only signal.
  bool get isRejected => !isSuccess;

  /// Points are proportional since 30 Aug 2026 —
  /// `round(score / total * quiz.points)` — and are paid on the first attempt
  /// only. A graded attempt that pays nothing despite correct answers means
  /// the points were banked earlier.
  bool get wasAlreadyRewarded =>
      !isRejected && solved && pointsEarned <= 0 && score > 0;

  /// After any attempt the server refuses to pay again, and course and lesson
  /// quizzes refuse the attempt outright, so re-offering the quiz would only
  /// walk the student into a rejection.
  bool get canRetry => !solved && !isRejected;

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
