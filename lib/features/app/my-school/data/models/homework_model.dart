import 'enrollment_model.dart' show SectionModel, localizedInt, localizedText;
import 'homework_question_model.dart';
import 'homework_submission_model.dart';

/// Every `type` the API sends. Verified live against real homework on
/// 2026-08-31, together with what each one requires at submit:
///
/// | type         | required fields    |
/// | ------------ | ------------------ |
/// | `mcq`        | `answers`          |
/// | `text`       | `content`          |
/// | `image`      | `file`             |
/// | `video`      | `file`             |
/// | `image_text` | `content` + `file` |
/// | `video_text` | `content` + `file` |
enum HomeworkType { mcq, text, image, video, imageText, videoText, other }

extension HomeworkTypeX on HomeworkType {
  /// Needs a written answer.
  bool get needsText =>
      this == HomeworkType.text ||
      this == HomeworkType.imageText ||
      this == HomeworkType.videoText;

  /// Needs a file, and which kind.
  bool get needsFile => needsImage || needsVideo;

  bool get needsImage =>
      this == HomeworkType.image || this == HomeworkType.imageText;

  bool get needsVideo =>
      this == HomeworkType.video || this == HomeworkType.videoText;
}

class HomeworkModel {
  final int? id;
  final String? title;
  final String? titleAr;
  final String? description;
  final String? descriptionAr;
  final HomeworkType type;
  final String? rawType;
  final String? correctionType;
  final int? maxScore;
  final String? dueAt;
  final SectionModel? section;
  final String? creatorName;
  final String? creatorNameAr;

  /// Only `GET homework/{id}` fills this; the list leaves it empty.
  final List<HomeworkQuestionModel> questions;

  /// Present on both the list and the detail — this is how the app knows
  /// whether the student already handed in.
  final HomeworkSubmissionModel? mySubmission;

  const HomeworkModel({
    this.id,
    this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    required this.type,
    this.rawType,
    this.correctionType,
    this.maxScore,
    this.dueAt,
    this.section,
    this.creatorName,
    this.creatorNameAr,
    required this.questions,
    this.mySubmission,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    final questions = json['questions'];
    final section = json['section'];
    final creator = json['creator'];
    final submission = json['my_submission'];
    final rawType = json['type']?.toString();

    return HomeworkModel(
      id: localizedInt(json['id']),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      type: switch (rawType?.toLowerCase()) {
        'mcq' => HomeworkType.mcq,
        'text' => HomeworkType.text,
        'image' => HomeworkType.image,
        'video' => HomeworkType.video,
        'image_text' => HomeworkType.imageText,
        'video_text' => HomeworkType.videoText,
        _ => HomeworkType.other,
      },
      rawType: rawType,
      correctionType: json['correction_type']?.toString(),
      maxScore: localizedInt(json['max_score']),
      dueAt: json['due_at']?.toString(),
      section: section is Map<String, dynamic>
          ? SectionModel.fromJson(section)
          : null,
      creatorName: creator is Map<String, dynamic>
          ? creator['name']?.toString()
          : null,
      creatorNameAr: creator is Map<String, dynamic>
          ? creator['name_ar']?.toString()
          : null,
      questions: questions is List
          ? questions
                .whereType<Map<String, dynamic>>()
                .map(HomeworkQuestionModel.fromJson)
                .toList()
          : const [],
      mySubmission: submission is Map<String, dynamic>
          ? HomeworkSubmissionModel.fromJson(submission)
          : null,
    );
  }

  bool get isSubmitted => mySubmission != null;

  /// A submission can be re-sent — verified live: posting again updates the
  /// same submission rather than being refused — so being submitted does not
  /// close the form.
  bool get isAnswerable => switch (type) {
    HomeworkType.mcq => questions.isNotEmpty,
    HomeworkType.other => false,
    _ => true,
  };

  String titleFor(String languageCode) =>
      localizedText(languageCode, title, titleAr);

  String descriptionFor(String languageCode) =>
      localizedText(languageCode, description, descriptionAr);

  String creatorNameFor(String languageCode) =>
      localizedText(languageCode, creatorName, creatorNameAr);

  /// `due_at` is an ISO timestamp; the UI only ever shows the day.
  String get dueDate {
    final due = dueAt;
    if (due == null || due.isEmpty) return '';
    final parsed = DateTime.tryParse(due);
    if (parsed == null) return due;
    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  bool get isOverdue {
    final due = DateTime.tryParse(dueAt ?? '');
    if (due == null || isSubmitted) return false;
    return due.toLocal().isBefore(DateTime.now());
  }
}
