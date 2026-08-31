import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/news_gallery_model.dart';
import 'news_repo.dart';

class NewsRepoImpl implements NewsRepo {
  final ApiServices _apiServices;

  NewsRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, PagedResult<NewsGalleryModel>>> getGalleries({
    int page = 1,
  }) async {
    try {
      final resp = await _apiServices.get(
        endPoint: pagedEndpoint(Urls.galleries, page),
      );
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final paginationData = responseData['data'];
        final data = paginationData is Map<String, dynamic>
            ? paginationData['data']
            : null;

        if (data is List) {
          final galleries = data
              .whereType<Map<String, dynamic>>()
              .map(NewsGalleryModel.fromJson)
              .toList();
          return right(
            PagedResult(
              items: galleries,
              pagination: PaginationModel.fromJson(
                paginationData is Map<String, dynamic> ? paginationData : null,
              ),
            ),
          );
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  ServerFailure _serverFailure(dynamic responseData) {
    return ServerFailure(
      responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? ErrorHandler.defaultMessage()
          : ErrorHandler.defaultMessage(),
    );
  }
}
