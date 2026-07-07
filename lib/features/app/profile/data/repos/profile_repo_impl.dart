import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../models/profile_model.dart';
import 'profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ApiServices _apiServices;

  ProfileRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      final resp = await _apiServices.get(endPoint: Urls.authMe);

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final profile = ProfileModel.fromJson(resp.data);
        await _cacheUser(profile.user);
        return right(profile);
      }

      return left(
        ServerFailure(
          resp.data['message']?.toString() ?? ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, ProfileModel>> updateProfile({
    required String name,
    required String nameAr,
    required String email,
    required String birthdate,
    required String gender,
    required String language,
    required List<String> interests,
    String? imagePath,
    String? imageName,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('name_ar', nameAr),
        MapEntry('email', email),
        MapEntry('birthdate', birthdate),
        MapEntry('gender', gender),
        MapEntry('language', language),
        MapEntry('interests', jsonEncode(interests)),
      ]);

      if (imagePath != null && imagePath.isNotEmpty) {
        final imageFile = File(imagePath);
        final uploadImageName = _normalizedImageName(imageName, imageFile);
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(
              await imageFile.readAsBytes(),
              filename: uploadImageName,
              contentType: _imageContentType(uploadImageName),
            ),
          ),
        );
      }

      final resp = await _apiServices.postFormData(
        endPoint: Urls.authProfile,
        data: formData,
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final profile = ProfileModel.fromJson(resp.data);
        await _cacheUser(profile.user);
        return right(profile);
      }

      return left(
        ServerFailure(
          resp.data['message']?.toString() ?? ErrorHandler.defaultMessage(),
        ),
      );
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  Future<void> _cacheUser(ProfileUserModel user) async {
    await CacheHelper.setString(key: 'user', value: jsonEncode(user.toJson()));
  }

  String _normalizedImageName(String? imageName, File imageFile) {
    final fallbackName = imageFile.uri.pathSegments.isNotEmpty
        ? imageFile.uri.pathSegments.last
        : 'profile_image.jpg';
    final rawName = imageName?.isNotEmpty == true ? imageName! : fallbackName;
    final lowerName = rawName.toLowerCase();

    if (lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp')) {
      return rawName;
    }

    return 'profile_image.jpg';
  }

  DioMediaType _imageContentType(String imageName) {
    final lowerName = imageName.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return DioMediaType('image', 'png');
    }
    if (lowerName.endsWith('.webp')) {
      return DioMediaType('image', 'webp');
    }
    return DioMediaType('image', 'jpeg');
  }
}
