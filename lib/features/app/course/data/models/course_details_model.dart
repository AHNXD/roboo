import '../../../../../core/utils/api_media_url_resolver.dart';
import '../../../../shared/topics/data/models/topic_model.dart';
import 'course_attachment_model.dart';
import 'course_place_model.dart';
import 'course_quiz_model.dart';
import 'lesson_model.dart';

class CourseDetailsModel {
  final int? id;
  final String? title;
  final String? titleAr;
  final String? description;
  final String? descriptionAr;
  final String? type;
  final String price;
  final String imageUrl;
  final String? ageGroup;
  final String? level;
  final List<String> whatWillLearn;
  final List<String> whatWillLearnAr;
  final String? demoVideoUrl;

  /// Poster frame for the intro video, signed and short-lived like the stream.
  final String? demoVideoThumbnail;
  final int sessionsCount;
  final int? durationHours;
  final String? startDate;
  final bool isActive;
  final int? topicId;

  /// Carries the topic's icon for the header badge. Null for a course with no
  /// topic.
  final TopicModel? topic;

  /// True once the student owns the course. Locked courses come back with an
  /// empty `lessons` list.
  final bool isUnlocked;

  final List<LessonModel> lessons;

  /// `progress.percentage` from the API. Null on older deployments, where the
  /// figure is derived from watched lessons instead.
  final double? progressPercentage;

  /// The real number of videos; `sessions_count` is the planned session count.
  final int? lessonsCount;
  final bool isFavorite;

  /// Centres where an offline course runs.
  final List<CoursePlaceModel> availablePlaces;

  /// Both are sent only for an unlocked course; empty otherwise.
  final List<CourseAttachmentModel> attachments;
  final List<CourseQuizModel> quizzes;

  const CourseDetailsModel({
    this.id,
    this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.type,
    required this.price,
    required this.imageUrl,
    this.ageGroup,
    this.level,
    required this.whatWillLearn,
    required this.whatWillLearnAr,
    this.demoVideoUrl,
    this.demoVideoThumbnail,
    required this.sessionsCount,
    this.durationHours,
    this.startDate,
    required this.isActive,
    this.topicId,
    this.topic,
    required this.isUnlocked,
    required this.lessons,
    required this.availablePlaces,
    this.attachments = const [],
    this.quizzes = const [],
    this.progressPercentage,
    this.lessonsCount,
    this.isFavorite = false,
  });

  factory CourseDetailsModel.fromJson(Map<String, dynamic> json) {
    final lessonsData = json['lessons'];
    final placesData = json['available_places'];
    final progressData = json['progress'];
    final attachmentsData = json['attachments'];
    final quizzesData = json['quizzes'];

    return CourseDetailsModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      type: json['type']?.toString(),
      price: json['price']?.toString() ?? '',
      imageUrl: ApiMediaUrlResolver.resolve(json['image']?.toString()),
      ageGroup: json['age_group']?.toString(),
      level: json['level']?.toString(),
      whatWillLearn: _parseStringList(json['what_will_learn']),
      whatWillLearnAr: _parseStringList(json['what_will_learn_ar']),
      demoVideoUrl: json['bunny_demo_video_hls_url']?.toString(),
      demoVideoThumbnail: json['demo_video_thumbnail']?.toString(),
      sessionsCount: _parseInt(json['sessions_count']) ?? 0,
      durationHours: _parseInt(json['duration_hours']),
      startDate: json['start_date']?.toString(),
      isActive: _parseBool(json['is_active']),
      topicId: _parseInt(json['topic_id']),
      topic: json['topic'] is Map<String, dynamic>
          ? TopicModel.fromJson(json['topic'] as Map<String, dynamic>)
          : null,
      isUnlocked: _parseBool(json['is_unlocked']),
      lessons: lessonsData is List
          ? lessonsData
                .whereType<Map<String, dynamic>>()
                .map(LessonModel.fromJson)
                .toList()
          : const [],
      attachments: attachmentsData is List
          ? attachmentsData
                .whereType<Map<String, dynamic>>()
                .map(CourseAttachmentModel.fromJson)
                .toList()
          : const [],
      quizzes: quizzesData is List
          ? quizzesData
                .whereType<Map<String, dynamic>>()
                .map(CourseQuizModel.fromJson)
                .toList()
          : const [],
      progressPercentage: progressData is Map<String, dynamic>
          ? _parseDouble(progressData['percentage'])
          : null,
      lessonsCount: _parseInt(json['lessons_count']),
      isFavorite: json['is_favorite'] == true,
      availablePlaces: placesData is List
          ? placesData
                .whereType<Map<String, dynamic>>()
                .map(CoursePlaceModel.fromJson)
                .toList()
          : const [],
    );
  }

  bool get isOnline => type?.toLowerCase() == 'online';

  String get displayPrice => price.isEmpty ? '' : '\$$price';

  /// Prefers the server's figure; falls back to counting watched lessons for
  /// deployments that do not send `progress` yet.
  double get watchedProgress {
    final serverProgress = progressPercentage;
    if (serverProgress != null) return serverProgress;

    if (lessons.isEmpty) return 0;
    final watched = lessons.where((lesson) => lesson.isWatched).length;
    return (watched / lessons.length) * 100;
  }

  /// Observed backend values: `easy`, `mid`, `hard`. `mid` is mapped onto the
  /// existing `medium` localization key rather than duplicating it; an
  /// unrecognised value falls back to the raw string so it is visibly wrong
  /// instead of silently mislabelled.
  String get levelLabelKey => switch (level?.toLowerCase()) {
    'easy' => 'easy',
    'mid' || 'medium' => 'medium',
    'hard' => 'hard',
    _ => level ?? '',
  };

  /// How many of the three difficulty marks are filled. 0 for an unknown level.
  int get levelRank => switch (level?.toLowerCase()) {
    'easy' => 1,
    'mid' || 'medium' => 2,
    'hard' => 3,
    _ => 0,
  };

  String titleFor(String languageCode) {
    if (languageCode == 'ar' && titleAr?.isNotEmpty == true) return titleAr!;
    return title?.isNotEmpty == true ? title! : titleAr ?? '';
  }

  List<String> whatWillLearnFor(String languageCode) {
    if (languageCode == 'ar' && whatWillLearnAr.isNotEmpty) {
      return whatWillLearnAr;
    }
    return whatWillLearn.isNotEmpty ? whatWillLearn : whatWillLearnAr;
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
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
