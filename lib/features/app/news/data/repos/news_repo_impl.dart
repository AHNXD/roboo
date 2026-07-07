import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/news_gallery_model.dart';
import 'news_repo.dart';

class NewsRepoImpl implements NewsRepo {
  final ApiServices _apiServices;

  static const String _galleriesEndpoint = 'galleries';

  NewsRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<NewsGalleryModel>>> getGalleries() async {
    try {
      final resp = await _apiServices.get(endPoint: _galleriesEndpoint);
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
          return right(galleries);
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
