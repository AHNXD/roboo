import 'package:dartz/dartz.dart';

import '../../../../../core/errors/failuer.dart';
import '../../../../../core/models/pagination_model.dart';
import '../models/homework_model.dart';

abstract class HomeworkRepo {
  /// [page] is 1-based; the backend fixes the page size at 25.
  Future<Either<Failure, PagedResult<HomeworkModel>>> getHomework({
    int page = 1,
  });

  Future<Either<Failure, HomeworkModel>> getHomeworkDetails({
    required int homeworkId,
  });

  /// [answers] maps a question id to the chosen option id.
  Future<Either<Failure, Unit>> submitMcqHomework({
    required int homeworkId,
    required Map<int, int> answers,
  });

  /// Everything that is not multiple choice. What the backend requires depends
  /// on the homework's type, verified live on 2026-08-31:
  ///
  /// - `text` — [content]
  /// - `image` / `video` — [filePath]
  /// - `image_text` / `video_text` — both
  ///
  /// Re-submitting updates the existing submission rather than being refused.
  Future<Either<Failure, Unit>> submitHomework({
    required int homeworkId,
    String? content,
    String? filePath,
  });
}
