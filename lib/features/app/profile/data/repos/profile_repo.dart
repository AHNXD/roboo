import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../models/profile_model.dart';

abstract class ProfileRepo {
  Future<Either<Failure, ProfileModel>> getProfile();

  Future<Either<Failure, ProfileModel>> updateProfile({
    required String name,
    required String nameAr,
    required String birthdate,
    required String gender,
    required String language,
    required List<String> heardAbout,
    String? fcmToken,
    String? imagePath,
    String? imageName,
  });

  /// Sends only `fcm_token`. `auth/profile` accepts a partial body, so the rest
  /// of the profile is left untouched.
  Future<Either<Failure, ProfileModel>> updateFcmToken({
    required String fcmToken,
  });
}
