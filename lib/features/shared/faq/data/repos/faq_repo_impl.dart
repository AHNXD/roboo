import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/faq_model.dart';
import 'faq_repo.dart';

class FaqRepoImpl implements FaqRepo {
  final ApiServices _apiServices;

  static const String _faqsEndpoint = 'faqs';

  FaqRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, List<FaqModel>>> getFaqs() async {
    try {
      final resp = await _apiServices.get(endPoint: _faqsEndpoint);
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final paginationData = responseData['data'];
        final items = paginationData is Map<String, dynamic>
            ? paginationData['data']
            : null;

        if (items is List) {
          final faqs = items
              .whereType<Map<String, dynamic>>()
              .map(FaqModel.fromJson)
              .toList();
          return right(faqs);
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(
        ServerFailure(
          responseData is Map<String, dynamic>
              ? responseData['message']?.toString() ??
                    ErrorHandler.defaultMessage()
              : ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }
}
