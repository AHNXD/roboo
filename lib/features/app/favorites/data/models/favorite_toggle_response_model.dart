class FavoriteToggleResponseModel {
  final List<int> attached;
  final List<int> detached;
  final String message;

  const FavoriteToggleResponseModel({
    required this.attached,
    required this.detached,
    required this.message,
  });

  factory FavoriteToggleResponseModel.fromJson({
    required Map<String, dynamic> json,
    required String message,
  }) {
    return FavoriteToggleResponseModel(
      attached: _parseIds(json['attached']),
      detached: _parseIds(json['detached']),
      message: message,
    );
  }

  static List<int> _parseIds(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) {
          if (item is int) return item;
          return int.tryParse(item?.toString() ?? '');
        })
        .whereType<int>()
        .toList();
  }
}
