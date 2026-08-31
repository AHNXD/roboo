import '../../../../../core/utils/api_media_url_resolver.dart';

/// A course resource. `type` is `link` or `file`; the payload carries `link_url`
/// for the former and `file_path` for the latter, and only ever fills one.
///
/// Only present on an unlocked course — the detail response omits
/// `attachments` entirely otherwise.
class CourseAttachmentModel {
  final int? id;
  final String? type;
  final String? title;
  final String? titleAr;

  /// Since 30 Aug 2026 the backend resolves this itself — one absolute address
  /// whether the attachment is an uploaded file or a pasted link.
  final String? resolvedUrl;

  final String? linkUrl;
  final String? filePath;

  const CourseAttachmentModel({
    this.id,
    this.type,
    this.title,
    this.titleAr,
    this.resolvedUrl,
    this.linkUrl,
    this.filePath,
  });

  factory CourseAttachmentModel.fromJson(Map<String, dynamic> json) {
    return CourseAttachmentModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      titleAr: json['title_ar']?.toString(),
      resolvedUrl: json['url']?.toString(),
      linkUrl: json['link_url']?.toString(),
      filePath: json['file_path']?.toString(),
    );
  }

  bool get isLink => type?.toLowerCase() == 'link';

  String titleFor(String languageCode) {
    if (languageCode == 'ar' && titleAr?.isNotEmpty == true) return titleAr!;
    return title?.isNotEmpty == true ? title! : titleAr ?? '';
  }

  /// Prefers the server-resolved `url`. The `link_url` / `file_path` fallback is
  /// kept for a deployment that has not shipped the resolver yet — a bare
  /// `file_path` is a storage path, so it still needs resolving to be openable.
  String get url {
    final resolved = resolvedUrl?.trim();
    if (resolved != null && resolved.isNotEmpty) return resolved;

    final link = linkUrl?.trim();
    if (link != null && link.isNotEmpty) return link;

    final file = filePath?.trim();
    if (file == null || file.isEmpty) return '';

    return ApiMediaUrlResolver.resolve(file);
  }
}
