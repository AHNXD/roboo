import '../../../../../core/utils/api_media_url_resolver.dart';

class NewsGalleryModel {
  final int? id;
  final String? title;
  final String? titleAr;
  final String? description;
  final String? descriptionAr;
  final String? createdAt;
  final String? updatedAt;
  final List<NewsGalleryMediaModel> mediaList;

  /// Videos attached to the post. Every seeded gallery has one, and they come
  /// in a separate `video_list` rather than mixed into `media_list`.
  final List<NewsGalleryVideoModel> videoList;

  const NewsGalleryModel({
    this.id,
    this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.createdAt,
    this.updatedAt,
    required this.mediaList,
    this.videoList = const [],
  });

  factory NewsGalleryModel.fromJson(Map<String, dynamic> json) {
    final media = json['media_list'];
    final videos = json['video_list'];

    return NewsGalleryModel(
      id: _parseInt(json['id']),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      description: json['description']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      mediaList: media is List
          ? media
                .whereType<Map<String, dynamic>>()
                .map(NewsGalleryMediaModel.fromJson)
                .toList()
          : const [],
      videoList: videos is List
          ? videos
                .whereType<Map<String, dynamic>>()
                .map(NewsGalleryVideoModel.fromJson)
                .toList()
          : const [],
    );
  }

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

  List<String> get videoUrls => videoList
      .map((video) => video.videoUrl)
      .where((url) => url.isNotEmpty)
      .toList();

  List<String> get imageUrls {
    return mediaList
        .map((media) => media.imageUrl)
        .where((imageUrl) => imageUrl.isNotEmpty)
        .toList();
  }

  String get displayDate {
    final date = DateTime.tryParse(createdAt ?? '');
    if (date == null) return '';

    final localDate = date.toLocal();
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    return '${localDate.year}/$month/$day';
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class NewsGalleryMediaModel {
  final int? id;
  final String collectionName;
  final String imageUrl;

  const NewsGalleryMediaModel({
    this.id,
    required this.collectionName,
    required this.imageUrl,
  });

  factory NewsGalleryMediaModel.fromJson(Map<String, dynamic> json) {
    return NewsGalleryMediaModel(
      id: NewsGalleryModel._parseInt(json['id']),
      collectionName: json['collection_name']?.toString() ?? '',
      imageUrl: ApiMediaUrlResolver.resolve(json['image_url']?.toString()),
    );
  }
}

/// One video on a news post. `video_url` is a plain mp4 on our own storage —
/// not a signed HLS stream like the course lessons.
class NewsGalleryVideoModel {
  final int? id;
  final String videoUrl;
  final String? mimeType;

  const NewsGalleryVideoModel({this.id, required this.videoUrl, this.mimeType});

  factory NewsGalleryVideoModel.fromJson(Map<String, dynamic> json) {
    return NewsGalleryVideoModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      videoUrl: ApiMediaUrlResolver.resolve(json['video_url']?.toString()),
      mimeType: json['mime_type']?.toString(),
    );
  }
}
