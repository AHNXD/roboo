import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/news_gallery_model.dart';

abstract class NewsRepo {
  /// [page] is 1-based; the backend fixes the page size at 25.
  Future<Either<Failure, PagedResult<NewsGalleryModel>>> getGalleries({
    int page = 1,
  });
}
