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
  Future<Either<Failure, ProfileModel>> updateFcmToken({
    required String fcmToken,
  }) async {
    try {
      final resp = await _apiServices.post(
        endPoint: Urls.authProfile,
        data: {'fcm_token': fcmToken},
      );

      return _profileResultFromResponse(resp.statusCode, resp.data);
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
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
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'name_ar': nameAr,
        'birthdate': birthdate,
        'gender': gender,
        'language': language,
        'heard_about': heardAbout,
      };
      if (fcmToken?.isNotEmpty == true) {
        data['fcm_token'] = fcmToken;
      }

      if (imagePath == null || imagePath.isEmpty) {
        final resp = await _apiServices.post(
          endPoint: Urls.authProfile,
          data: data,
        );

        return _profileResultFromResponse(resp.statusCode, resp.data);
      }

      final formData = FormData();
      formData.fields.addAll([
        MapEntry('name', data['name'].toString()),
        MapEntry('name_ar', data['name_ar'].toString()),
        MapEntry('birthdate', data['birthdate'].toString()),
        MapEntry('gender', data['gender'].toString()),
        MapEntry('language', data['language'].toString()),
      ]);
      for (final source in heardAbout) {
        formData.fields.add(MapEntry('heard_about[]', source));
      }
      if (data['fcm_token'] != null) {
        formData.fields.add(
          MapEntry('fcm_token', data['fcm_token'].toString()),
        );
      }

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

      final resp = await _apiServices.postFormData(
        endPoint: Urls.authProfile,
        data: formData,
      );

      return _profileResultFromResponse(resp.statusCode, resp.data);
    } catch (e) {
      return left(ErrorHandler.handle(e));
    }
  }

  Future<Either<Failure, ProfileModel>> _profileResultFromResponse(
    int? statusCode,
    dynamic responseData,
  ) async {
    if (statusCode == 200 &&
        responseData is Map<String, dynamic> &&
        responseData['success'] == true) {
      final profile = ProfileModel.fromJson(responseData);
      final cachedUser = _cachedUser();
      final user = cachedUser == null
          ? profile.user
          : profile.user.mergeMissingFrom(cachedUser);
      await _cacheUser(user);
      return right(ProfileModel(message: profile.message, user: user));
    }

    return left(
      ServerFailure(
        responseData is Map<String, dynamic>
            ? responseData['message']?.toString() ??
                  ErrorHandler.defaultMessage()
            : ErrorHandler.defaultMessage(),
      ),
    );
  }

  Future<void> _cacheUser(ProfileUserModel user) async {
    await CacheHelper.setString(key: 'user', value: jsonEncode(user.toJson()));
  }

  ProfileUserModel? _cachedUser() {
    final cachedUser = CacheHelper.getData(key: 'user')?.toString();
    if (cachedUser == null || cachedUser.isEmpty) return null;

    try {
      final json = jsonDecode(cachedUser);
      if (json is Map<String, dynamic>) {
        return ProfileUserModel.fromJson(json);
      }
    } catch (_) {
      return null;
    }

    return null;
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
