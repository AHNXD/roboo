import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/feedback_request_model.dart';
import '../../../data/models/feedback_response_model.dart';
import '../../../data/repos/feedback_repo.dart';

part 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackRepo _feedbackRepo;

  FeedbackCubit(this._feedbackRepo) : super(FeedbackInitial());

  Future<void> submitFeedback({
    required int rating,
    required String note,
  }) async {
    emit(FeedbackSubmitting());
    final result = await _feedbackRepo.submitFeedback(
      FeedbackRequestModel(rating: rating, note: note),
    );
    result.fold(
      (failure) => emit(FeedbackError(errorMsg: failure.message)),
      (response) => emit(FeedbackSubmitSuccess(response: response)),
    );
  }
}
