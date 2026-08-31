import '../../../../shared/topics/data/models/topic_model.dart';
import 'question_model.dart';

class QuizModel {
  final int? id;
  final String? title;
  final String? titleAr;
  final int? topicId;
  final int? timeLimit;
  final int points;

  /// Not returned by `GET quizzes`; only `GET quizzes/{id}` exposes it today.
  /// Parsed defensively so the list picks it up if the backend starts sending it.
  final int? questionsCount;

  final TopicModel? topic;

  /// True once the student holds a points-awarded attempt. Present on both the
  /// list and the detail; absent on older deployments, which reads as false.
  final bool solved;

  /// Only `GET quizzes/{id}` returns questions; empty for list items.
  final List<QuestionModel> questions;

  const QuizModel({
    this.id,
    this.title,
    this.titleAr,
    this.topicId,
    this.timeLimit,
    required this.points,
    this.questionsCount,
    this.topic,
    this.solved = false,
    this.questions = const [],
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final topicData = json['topic'];
    final questionsData = json['questions'];

    return QuizModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      topicId: _parseInt(json['topic_id']),
      timeLimit: _parseInt(json['time_limit']),
      points: _parseInt(json['points']) ?? 0,
      questionsCount: _parseInt(json['questions_count']),
      topic: topicData is Map<String, dynamic>
          ? TopicModel.fromJson(topicData)
          : null,
      solved: json['solved'] == true,
      questions: questionsData is List
          ? questionsData
                .whereType<Map<String, dynamic>>()
                .map(QuestionModel.fromJson)
                .toList()
          : const [],
    );
  }

  String titleFor(String languageCode) {
    if (languageCode == 'ar' && titleAr?.isNotEmpty == true) {
      return titleAr!;
    }
    return title?.isNotEmpty == true ? title! : titleAr ?? '';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
