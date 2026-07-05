class FeedbackResponseModel {
  final int? id;
  final int? userId;
  final int? rating;
  final String? note;
  final String? createdAt;
  final String? updatedAt;
  final String message;

  const FeedbackResponseModel({
    this.id,
    this.userId,
    this.rating,
    this.note,
    this.createdAt,
    this.updatedAt,
    required this.message,
  });

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final feedbackData = data is Map<String, dynamic>
        ? data
        : <String, dynamic>{};

    return FeedbackResponseModel(
      id: _parseInt(feedbackData['id']),
      userId: _parseInt(feedbackData['user_id']),
      rating: _parseInt(feedbackData['rating']),
      note: feedbackData['note']?.toString(),
      createdAt: feedbackData['created_at']?.toString(),
      updatedAt: feedbackData['updated_at']?.toString(),
      message: json['message']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
