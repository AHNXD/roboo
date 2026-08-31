import 'answer_model.dart';

class QuestionModel {
  final int? id;
  final String? questionText;
  final String? questionTextAr;
  final List<AnswerModel> answers;

  const QuestionModel({
    this.id,
    this.questionText,
    this.questionTextAr,
    required this.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final answersData = json['answers'];

    return QuestionModel(
      id: _parseInt(json['id']),
      questionText: json['question_text']?.toString(),
      questionTextAr: json['question_text_ar']?.toString(),
      answers: answersData is List
          ? answersData
                .whereType<Map<String, dynamic>>()
                .map(AnswerModel.fromJson)
                .toList()
          : const [],
    );
  }

  String questionTextFor(String languageCode) {
    if (languageCode == 'ar' && questionTextAr?.isNotEmpty == true) {
      return questionTextAr!;
    }
    return questionText?.isNotEmpty == true
        ? questionText!
        : questionTextAr ?? '';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
