/// `POST courses/favorite` answers with Laravel's native `toggle()` shape:
/// sending an id that is already a favorite un-favorites it.
class CourseFavoriteToggleModel {
  final List<int> attached;
  final List<int> detached;
  final List<int> updated;

  const CourseFavoriteToggleModel({
    required this.attached,
    required this.detached,
    required this.updated,
  });

  factory CourseFavoriteToggleModel.fromJson(Map<String, dynamic> json) {
    return CourseFavoriteToggleModel(
      attached: _parseIds(json['attached']),
      detached: _parseIds(json['detached']),
      updated: _parseIds(json['updated']),
    );
  }

  static List<int> _parseIds(dynamic value) {
    if (value is! List) return const [];

    return value
        .map((item) {
          if (item is int) return item;
          if (item is num) return item.toInt();
          return int.tryParse(item?.toString() ?? '');
        })
        .whereType<int>()
        .toList();
  }
}
