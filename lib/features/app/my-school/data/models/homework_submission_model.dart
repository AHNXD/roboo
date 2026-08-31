import 'enrollment_model.dart' show localizedInt;
import 'homework_question_result_model.dart';

/// Statuses seen on the API: `missing`, `submitted`, `corrected`, `returned`.
enum SubmissionStatus { missing, submitted, corrected, returned, unknown }

class HomeworkSubmissionModel {
  final int? id;
  final int? homeworkId;

  /// Free-text answer for `type: text` homework.
  final String? content;

  /// Selected option ids for `type: mcq` homework.
  final List<int> answers;

  final SubmissionStatus status;
  final int? score;
  final String? feedback;

  /// A mark stays hidden until the teacher releases it.
  final bool isScoreReleased;

  final String? submittedAt;
  final String? correctedAt;

  /// Per-question correction, released with the mark. Null on the wire while
  /// withheld; empty here.
  final List<HomeworkQuestionResultModel> questionResults;

  /// The file the student uploaded, for the image and video types.
  final HomeworkAttachmentModel? attachment;

  const HomeworkSubmissionModel({
    this.id,
    this.homeworkId,
    this.content,
    required this.answers,
    required this.status,
    this.score,
    this.feedback,
    required this.isScoreReleased,
    this.submittedAt,
    this.correctedAt,
    this.questionResults = const [],
    this.attachment,
  });

  factory HomeworkSubmissionModel.fromJson(Map<String, dynamic> json) {
    final answers = json['answers'];
    final questionResults = json['question_results'];

    return HomeworkSubmissionModel(
      id: localizedInt(json['id']),
      homeworkId: localizedInt(json['homework_id']),
      content: json['content']?.toString(),
      answers: answers is List
          ? answers.map(localizedInt).whereType<int>().toList()
          : const [],
      status: _parseStatus(json['status']),
      score: localizedInt(json['score']),
      feedback: json['feedback']?.toString(),
      isScoreReleased: json['is_score_released'] == true,
      attachment: json['attachment'] is Map<String, dynamic>
          ? HomeworkAttachmentModel.fromJson(
              json['attachment'] as Map<String, dynamic>,
            )
          : null,
      submittedAt: json['submitted_at']?.toString(),
      correctedAt: json['corrected_at']?.toString(),
      questionResults: questionResults is List
          ? questionResults
                .whereType<Map<String, dynamic>>()
                .map(HomeworkQuestionResultModel.fromJson)
                .toList()
          : const [],
    );
  }

  /// Correction detail only exists for MCQ homework, and only after release.
  HomeworkQuestionResultModel? resultFor(int? questionId) {
    if (questionId == null) return null;

    for (final result in questionResults) {
      if (result.questionId == questionId) return result;
    }
    return null;
  }

  /// Never show a mark the teacher has not released. `is_score_released` is the
  /// backend's own gate, so it alone decides — also checking the status would
  /// hide a released mark if the two ever disagree.
  bool get hasVisibleScore => isScoreReleased && score != null;

  static SubmissionStatus _parseStatus(dynamic value) {
    return switch (value?.toString().toLowerCase()) {
      'missing' => SubmissionStatus.missing,
      'submitted' => SubmissionStatus.submitted,
      'corrected' => SubmissionStatus.corrected,
      'returned' => SubmissionStatus.returned,
      _ => SubmissionStatus.unknown,
    };
  }
}

/// A file on a submission. `url` is absolute and public.
class HomeworkAttachmentModel {
  final int? id;
  final String? name;
  final String? mimeType;
  final String url;

  const HomeworkAttachmentModel({
    this.id,
    this.name,
    this.mimeType,
    required this.url,
  });

  factory HomeworkAttachmentModel.fromJson(Map<String, dynamic> json) {
    return HomeworkAttachmentModel(
      id: localizedInt(json['id']),
      name: json['name']?.toString(),
      mimeType: json['mime_type']?.toString(),
      url: json['url']?.toString() ?? '',
    );
  }

  bool get isImage => mimeType?.startsWith('image/') == true;

  bool get isVideo => mimeType?.startsWith('video/') == true;
}
