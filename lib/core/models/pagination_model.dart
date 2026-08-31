/// The paging metadata the API sends, in either of the two shapes it uses:
/// a Laravel paginator, where the fields sit beside the list at the root of
/// `data` (products, orders, favorites, galleries, faqs), or a small
/// `pagination` object next to a named array (courses, quizzes, homework).
/// Both carry the same four fields, so one parser covers them.
///
/// `per_page` is fixed at 25 by the backend — sending it is ignored — so only
/// `page` is worth requesting.
class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationModel({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 25,
    this.total = 0,
  });

  /// A response with no paging metadata is treated as a single complete page,
  /// so a caller can never loop forever asking for page 2 of a plain array.
  static const PaginationModel single = PaginationModel();

  factory PaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return single;

    final currentPage = _parseInt(json['current_page']) ?? 1;
    final lastPage = _parseInt(json['last_page']) ?? currentPage;

    return PaginationModel(
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: _parseInt(json['per_page']) ?? 25,
      total: _parseInt(json['total']) ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;

  int get nextPage => currentPage + 1;

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

/// One page of a list, plus where that page sits in the whole.
class PagedResult<T> {
  final List<T> items;
  final PaginationModel pagination;

  const PagedResult({required this.items, required this.pagination});

  bool get hasMore => pagination.hasMore;

  int get nextPage => pagination.nextPage;
}

/// Adds `?page=N` to an endpoint, leaving page 1 as the bare path so the
/// request looks exactly as it did before pagination existed.
String pagedEndpoint(String path, int page) {
  if (page <= 1) return path;

  return Uri(path: path, queryParameters: {'page': page.toString()}).toString();
}
