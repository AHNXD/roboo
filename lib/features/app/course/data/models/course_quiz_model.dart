/// A quiz attached to a course, as it appears on the course detail. It is a
/// summary — the questions come from `GET quizzes/{id}` when the student opens
/// it. Only present on an unlocked course.
class CourseQuizModel {
  final int? id;
  final String? title;
  final String? titleAr;
  final int? timeLimit;
  final int points;

  /// True once this student has earned the quiz's points. Computed server-side
  /// and sent with every embedded quiz, so a card can show "completed" without
  /// opening the quiz first.
  final bool solved;

  const CourseQuizModel({
    this.id,
    this.title,
    this.titleAr,
    this.timeLimit,
    required this.points,
    this.solved = false,
  });

  factory CourseQuizModel.fromJson(Map<String, dynamic> json) {
    return CourseQuizModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      timeLimit: _parseInt(json['time_limit']),
      points: _parseInt(json['points']) ?? 0,
      solved: json['solved'] == true,
    );
  }

  int get durationMinutes => timeLimit ?? 0;

  String titleFor(String languageCode) {
    if (languageCode == 'ar' && titleAr?.isNotEmpty == true) return titleAr!;
    return title?.isNotEmpty == true ? title! : titleAr ?? '';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
