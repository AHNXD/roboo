import 'enrollment_model.dart' show localizedInt, localizedText;

class HomeworkQuestionModel {
  final int? id;
  final String? question;
  final String? questionAr;
  final int? order;
  final int? score;
  final List<HomeworkOptionModel> options;

  const HomeworkQuestionModel({
    this.id,
    this.question,
    this.questionAr,
    this.order,
    this.score,
    required this.options,
  });

  factory HomeworkQuestionModel.fromJson(Map<String, dynamic> json) {
    final options = json['options'];

    return HomeworkQuestionModel(
      id: localizedInt(json['id']),
      question: json['question']?.toString(),
      questionAr: json['question_ar']?.toString(),
      order: localizedInt(json['order']),
      score: localizedInt(json['score']),
      options: options is List
          ? options
                .whereType<Map<String, dynamic>>()
                .map(HomeworkOptionModel.fromJson)
                .toList()
          : const [],
    );
  }

  String questionFor(String languageCode) =>
      localizedText(languageCode, question, questionAr);
}

/// The student payload deliberately carries no `is_correct`; homework is graded
/// server-side, unlike quizzes.
class HomeworkOptionModel {
  final int? id;
  final String? label;
  final String? labelAr;
  final int? order;

  const HomeworkOptionModel({this.id, this.label, this.labelAr, this.order});

  factory HomeworkOptionModel.fromJson(Map<String, dynamic> json) {
    return HomeworkOptionModel(
      id: localizedInt(json['id']),
      label: json['label']?.toString(),
      labelAr: json['label_ar']?.toString(),
      order: localizedInt(json['order']),
    );
  }

  /// `label_ar` is only the Arabic wording of the option — never a hint about
  /// whether it is the right one.
  String labelFor(String languageCode) =>
      localizedText(languageCode, label, labelAr);
}
