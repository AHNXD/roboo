import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../models/app_settings_model.dart';
import 'app_settings_repo.dart';

class AppSettingsRepoImpl implements AppSettingsRepo {
  final ApiServices _apiServices;

  AppSettingsRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, AppSettingsModel>> getSettings() async {
    try {
      final resp = await _apiServices.get(endPoint: Urls.settings);
      final responseData = resp.data;

      if (resp.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        return right(
          data is Map<String, dynamic>
              ? AppSettingsModel.fromJson(data)
              : AppSettingsModel.empty,
        );
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
