/// One entry in the bell icon's history. `meta` carries the same payload the
/// FCM push sends, so a tap here routes exactly like a tap on the push itself.
class NotificationModel {
  final int? id;
  final String? type;
  final String? title;
  final String? body;
  final Map<String, dynamic> meta;
  final bool isRead;
  final String? createdAt;

  const NotificationModel({
    this.id,
    this.type,
    this.title,
    this.body,
    this.meta = const {},
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final metaData = json['meta'];

    return NotificationModel(
      id: _parseInt(json['id']),
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      body: json['body']?.toString(),
      meta: metaData is Map<String, dynamic>
          ? metaData
          : const <String, dynamic>{},
      isRead: json['is_read'] == true,
      createdAt: json['created_at']?.toString(),
    );
  }

  /// The course this notification points at, if any. Ids arrive as strings in
  /// the FCM payload, so they are parsed rather than cast.
  int? get courseId => _parseInt(meta['course_id']);

  bool get isCourseNotification => type == 'new_course' && courseId != null;

  String get displayDate {
    final date = DateTime.tryParse(createdAt ?? '');
    if (date == null) return '';

    final localDate = date.toLocal();
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    return '${localDate.year}/$month/$day · $hour:$minute';
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      meta: meta,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
