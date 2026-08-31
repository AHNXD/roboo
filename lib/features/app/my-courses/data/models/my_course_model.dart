import '../../../../shared/topics/data/models/topic_model.dart';
import '../../../../../core/utils/api_media_url_resolver.dart';

/// `GET my/courses` — the student's purchased, active courses. The item is a
/// course plus the same `is_unlocked` / `progress` the course detail computes,
/// so there is no second progress system in the app either.
class MyCourseModel {
  final int? id;
  final String? title;
  final String? titleAr;
  final String? description;
  final String? descriptionAr;
  final String? type;
  final String imageUrl;
  final int? topicId;

  /// Carries the topic's icon for the card badge. Null for a course with no
  /// topic — course 11 is one today.
  final TopicModel? topic;
  final bool isUnlocked;
  final CourseProgressModel progress;
  final int? lessonsCount;
  final bool isFavorite;

  const MyCourseModel({
    this.id,
    this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.type,
    required this.imageUrl,
    this.topicId,
    this.topic,
    required this.isUnlocked,
    required this.progress,
    this.lessonsCount,
    this.isFavorite = false,
  });

  factory MyCourseModel.fromJson(Map<String, dynamic> json) {
    return MyCourseModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      type: json['type']?.toString(),
      imageUrl: ApiMediaUrlResolver.resolve(json['image']?.toString()),
      topicId: _parseInt(json['topic_id']),
      topic: json['topic'] is Map<String, dynamic>
          ? TopicModel.fromJson(json['topic'] as Map<String, dynamic>)
          : null,
      isUnlocked: json['is_unlocked'] == true,
      progress: CourseProgressModel.fromJson(json['progress']),
      lessonsCount: _parseInt(json['lessons_count']),
      isFavorite: json['is_favorite'] == true,
    );
  }

  bool get isOnline => type?.toLowerCase() == 'online';

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

class CourseProgressModel {
  final int watchedCount;
  final int totalCount;
  final double percentage;

  const CourseProgressModel({
    required this.watchedCount,
    required this.totalCount,
    required this.percentage,
  });

  /// Tolerates a missing `progress` object entirely — an older deployment
  /// simply shows 0%.
  factory CourseProgressModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const CourseProgressModel(
        watchedCount: 0,
        totalCount: 0,
        percentage: 0,
      );
    }

    return CourseProgressModel(
      watchedCount: _parseInt(json['watched_count']) ?? 0,
      totalCount: _parseInt(json['total_count']) ?? 0,
      percentage: _parseDouble(json['percentage']) ?? 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
