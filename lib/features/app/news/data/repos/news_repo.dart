import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/news_gallery_model.dart';

abstract class NewsRepo {
  Future<Either<Failure, List<NewsGalleryModel>>> getGalleries();
}
