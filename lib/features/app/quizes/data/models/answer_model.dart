/// The backend stopped shipping `is_correct` on 30 Aug 2026 — it was the answer
/// key, sent before the student had answered. Correctness now reaches the app
/// only through `question_results` on the submit response, which is why the
/// quiz screen no longer reveals anything mid-quiz.
class AnswerModel {
  final int? id;
  final String? answerText;
  final String? answerTextAr;

  const AnswerModel({this.id, this.answerText, this.answerTextAr});

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: _parseInt(json['id']),
      answerText: json['answer_text']?.toString(),
      answerTextAr: json['answer_text_ar']?.toString(),
    );
  }

  String answerTextFor(String languageCode) {
    if (languageCode == 'ar' && answerTextAr?.isNotEmpty == true) {
      return answerTextAr!;
    }
    return answerText?.isNotEmpty == true ? answerText! : answerTextAr ?? '';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
