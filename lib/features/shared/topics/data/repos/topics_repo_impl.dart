import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/topic_model.dart';
import 'topics_repo.dart';

class TopicsRepoImpl implements TopicsRepo {
  final ApiServices _apiServices;

  TopicsRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<TopicModel>>> getTopics() async {
    try {
      final resp = await _apiServices.get(endPoint: Urls.topics);
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is List) {
          final topics = data
              .whereType<Map<String, dynamic>>()
              .map(TopicModel.fromJson)
              .toList();
          return right(topics);
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
