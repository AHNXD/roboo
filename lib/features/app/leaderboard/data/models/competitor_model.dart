class Competitor {
  final int rank;
  final String name;
  final int points;
  final String image;
  final bool isCurrentUser;

  Competitor({
    required this.rank,
    required this.name,
    required this.points,
    required this.image,
    this.isCurrentUser = false,
  });
}
