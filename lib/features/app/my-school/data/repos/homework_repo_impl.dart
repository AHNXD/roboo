import 'package:dio/dio.dart';
import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../../core/Api_services/api_services.dart';
import '../../../../../core/Api_services/urls.dart';
import '../../../../../core/errors/error_handler.dart';
import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/homework_model.dart';
import 'homework_repo.dart';

class HomeworkRepoImpl implements HomeworkRepo {
  final ApiServices _apiServices;

  HomeworkRepoImpl(this._apiServices);

  @override
  Future<Either<Failure, PagedResult<HomeworkModel>>> getHomework({
    int page = 1,
  }) async {
    try {
      final response = await _apiServices.get(
        endPoint: pagedEndpoint(Urls.homework, page),
      );
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];
        final homeworkData = data is Map<String, dynamic>
            ? data['homework']
            : null;

        // An unenrolled student gets an empty list, not an error.
        if (homeworkData is List) {
          final homework = homeworkData
              .whereType<Map<String, dynamic>>()
              .map(HomeworkModel.fromJson)
              .toList();
          return right(
            PagedResult(
              items: homework,
              pagination: PaginationModel.fromJson(
                data is Map<String, dynamic> &&
                        data['pagination'] is Map<String, dynamic>
                    ? data['pagination'] as Map<String, dynamic>
                    : null,
              ),
            ),
          );
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, HomeworkModel>> getHomeworkDetails({
    required int homeworkId,
  }) async {
    try {
      final response = await _apiServices.get(
        endPoint: Urls.homeworkDetails(homeworkId),
      );
      final responseData = response.data;

      if (response.statusCode == 200 &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          return right(HomeworkModel.fromJson(data));
        }

        return left(ServerFailure(ErrorHandler.defaultMessage()));
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitMcqHomework({
    required int homeworkId,
    required Map<int, int> answers,
  }) {
    // The collection documents both a list and a map; the list form is the one
    // with a request example, so that is what the app sends.
    return _submit(homeworkId, {
      'answers': answers.entries
          .map((entry) => {'question_id': entry.key, 'option_id': entry.value})
          .toList(),
    });
  }

  @override
  Future<Either<Failure, Unit>> submitHomework({
    required int homeworkId,
    String? content,
    String? filePath,
  }) async {
    try {
      // Multipart either way: a file may ride along, and the backend reads the
      // written answer from the same form.
      final formData = FormData.fromMap({
        if (content != null && content.trim().isNotEmpty)
          'content': content.trim(),
        if (filePath != null && filePath.isNotEmpty)
          'file': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split(Platform.pathSeparator).last,
          ),
      });

      final response = await _apiServices.postFormData(
        endPoint: Urls.homeworkSubmit(homeworkId),
        data: formData,
      );
      final responseData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        return right(unit);
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
    }
  }

  Future<Either<Failure, Unit>> _submit(
    int homeworkId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _apiServices.post(
        endPoint: Urls.homeworkSubmit(homeworkId),
        data: body,
      );
      final responseData = response.data;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData is Map<String, dynamic> &&
          responseData['success'] == true) {
        return right(unit);
      }

      return left(_serverFailure(responseData));
    } catch (error) {
      return left(ErrorHandler.handle(error));
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
