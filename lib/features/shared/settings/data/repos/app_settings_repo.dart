import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/app_settings_model.dart';

abstract class AppSettingsRepo {
  /// Public — no token required.
  Future<Either<Failure, AppSettingsModel>> getSettings();
}
