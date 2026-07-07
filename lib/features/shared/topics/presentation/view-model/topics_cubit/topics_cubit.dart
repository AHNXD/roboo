import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/topic_model.dart';
import '../../../data/repos/topics_repo.dart';

part 'topics_state.dart';

class TopicsCubit extends Cubit<TopicsState> {
  final TopicsRepo _topicsRepo;

  TopicsCubit(this._topicsRepo) : super(TopicsInitial());

  Future<void> getTopics() async {
    emit(TopicsLoading());
    final result = await _topicsRepo.getTopics();
    result.fold(
      (failure) => emit(TopicsError(errorMsg: failure.message)),
      (topics) => topics.isEmpty
          ? emit(TopicsEmpty())
          : emit(TopicsLoaded(topics: topics)),
    );
  }
}
