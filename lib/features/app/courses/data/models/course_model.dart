import '../../../../../core/utils/api_media_url_resolver.dart';
import '../../../../shared/topics/data/models/topic_model.dart';

class CourseModel {
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
  final int sessionsCount;
  final int? durationHours;
  final String? startDate;
  final bool isActive;
  final int? topicId;
  final TopicModel? topic;

  /// Only `GET courses/featured` sets this; it is how many students bought the
  /// course, and the reason that list is ordered the way it is.
  final int? purchasesCount;

  /// The real number of videos in the course. `sessions_count` is the planned
  /// session count and is not the same thing.
  final int? lessonsCount;

  /// Server-computed for the authenticated student; false for a guest.
  final bool isFavorite;

  const CourseModel({
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
    required this.sessionsCount,
    this.durationHours,
    this.startDate,
    required this.isActive,
    this.topicId,
    this.topic,
    this.purchasesCount,
    this.lessonsCount,
    this.isFavorite = false,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final topicData = json['topic'];

    return CourseModel(
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
      sessionsCount: _parseInt(json['sessions_count']) ?? 0,
      durationHours: _parseInt(json['duration_hours']),
      startDate: json['start_date']?.toString(),
      isActive: _parseBool(json['is_active']),
      topicId: _parseInt(json['topic_id']),
      topic: topicData is Map<String, dynamic>
          ? TopicModel.fromJson(topicData)
          : null,
      purchasesCount: _parseInt(json['purchases_count']),
      lessonsCount: _parseInt(json['lessons_count']),
      isFavorite: json['is_favorite'] == true,
    );
  }

  bool get isOnline => type?.toLowerCase() == 'online';

  String titleFor(String languageCode) {
    if (languageCode == 'ar' && titleAr?.isNotEmpty == true) {
      return titleAr!;
    }
    return title?.isNotEmpty == true ? title! : titleAr ?? '';
  }

  String descriptionFor(String languageCode) {
    if (languageCode == 'ar' && descriptionAr?.isNotEmpty == true) {
      return descriptionAr!;
    }
    return description?.isNotEmpty == true ? description! : descriptionAr ?? '';
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
