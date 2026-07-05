class FeedbackRequestModel {
  final int rating;
  final String note;

  const FeedbackRequestModel({required this.rating, required this.note});

  Map<String, dynamic> toJson() {
    return {'rating': rating, 'note': note};
  }
}
