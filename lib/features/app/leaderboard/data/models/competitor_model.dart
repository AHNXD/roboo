class Competitor {
  final int rank;
  final String name;
  final int points;
  final String image;
  final bool isCurrentUser;

  const Competitor({
    required this.rank,
    required this.name,
    required this.points,
    required this.image,
    this.isCurrentUser = false,
  });

  factory Competitor.fromJson(Map<String, dynamic> json, {required int rank}) {
    return Competitor(
      rank: rank,
      name: json['name']?.toString() ?? '',
      points: _parseInt(json['points']) ?? 0,
      image: json['image']?.toString() ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
