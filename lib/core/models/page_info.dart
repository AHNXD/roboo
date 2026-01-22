class PageInfo {
  final int currentPage;
  final int perPage;
  final int lastPage;
  final int total;

  PageInfo({
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
    required this.total,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      currentPage: json['current_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'last_page': lastPage,
      'total': total,
    };
  }
}
