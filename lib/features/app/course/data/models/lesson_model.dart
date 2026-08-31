import 'course_quiz_model.dart';

class LessonModel {
  final int? id;
  final int? courseId;
  final String? title;
  final String? titleAr;
  final String? description;
  final String? descriptionAr;
  final List<String> whatWillLearn;
  final List<String> whatWillLearnAr;

  /// Absent on locked lessons — the backend only ships the HLS url for content
  /// the student may watch. Prefers the plain `video_url`; older deployments
  /// only send `bunny_video_hls_url`. Both are the same signed HLS stream.
  final String? videoUrl;

  /// Poster frame for the player. Absent when the lesson has no video, and
  /// signed with the same short expiry as the stream, so it is read from the
  /// response each time rather than cached.
  final String? videoThumbnail;

  final int durationSeconds;
  final int? order;
  final bool isFreePreview;
  final bool isLocked;
  final bool isWatched;

  /// A quiz that belongs to this lesson rather than to the course as a whole.
  /// Only some lessons have one.
  final CourseQuizModel? quiz;

  const LessonModel({
    this.id,
    this.courseId,
    this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    required this.whatWillLearn,
    required this.whatWillLearnAr,
    this.videoUrl,
    this.videoThumbnail,
    required this.durationSeconds,
    this.order,
    required this.isFreePreview,
    required this.isLocked,
    required this.isWatched,
    this.quiz,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['course_id']),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      whatWillLearn: _parseStringList(json['what_will_learn']),
      whatWillLearnAr: _parseStringList(json['what_will_learn_ar']),
      videoUrl: (json['video_url'] ?? json['bunny_video_hls_url'])?.toString(),
      videoThumbnail: json['video_thumbnail']?.toString(),
      durationSeconds: _parseInt(json['duration_seconds']) ?? 0,
      order: _parseInt(json['order']),
      isFreePreview: _parseBool(json['is_free_preview']),
      isLocked: _parseBool(json['is_locked']),
      isWatched: _parseBool(json['is_watched']),
      quiz: json['quiz'] is Map<String, dynamic>
          ? CourseQuizModel.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
    );
  }

  int get durationMinutes => (durationSeconds / 60).round();

  /// The backend ships the stream only for lessons the student may watch, so a
  /// lesson can be unlocked and still have no video uploaded yet.
  bool get hasVideo => videoUrl?.trim().isNotEmpty == true;

  String titleFor(String languageCode) {
    if (languageCode == 'ar' && titleAr?.isNotEmpty == true) return titleAr!;
    return title?.isNotEmpty == true ? title! : titleAr ?? '';
  }

  String descriptionFor(String languageCode) {
    if (languageCode == 'ar' && descriptionAr?.isNotEmpty == true) {
      return descriptionAr!;
    }
    return description?.isNotEmpty == true ? description! : descriptionAr ?? '';
  }

  List<String> whatWillLearnFor(String languageCode) {
    if (languageCode == 'ar' && whatWillLearnAr.isNotEmpty) {
      return whatWillLearnAr;
    }
    return whatWillLearn.isNotEmpty ? whatWillLearn : whatWillLearnAr;
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

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }
}
