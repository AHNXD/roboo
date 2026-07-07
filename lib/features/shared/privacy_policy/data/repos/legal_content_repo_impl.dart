import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/legal_content_model.dart';
import 'legal_content_repo.dart';

class LegalContentRepoImpl implements LegalContentRepo {
  final ApiServices _apiServices;

  LegalContentRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, LegalContentModel>> getPrivacyPolicy() {
    return _getLegalContent(Urls.privacyPolicy);
  }

  @override
  Future<Either<Failure, LegalContentModel>> getTermsOfUse() {
    return _getLegalContent(Urls.termsOfUse);
  }

  Future<Either<Failure, LegalContentModel>> _getLegalContent(
    String endpoint,
  ) async {
    try {
      final resp = await _apiServices.get(endPoint: endpoint);
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(LegalContentModel.fromJson(data));
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
