import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/news_gallery_model.dart';
import '../../../data/repos/news_repo.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepo _newsRepo;

  NewsCubit(this._newsRepo) : super(const NewsInitial());

  Future<void> getGalleries() async {
    emit(const NewsLoading());

    final result = await _newsRepo.getGalleries();
    result.fold((failure) => emit(NewsError(errorMsg: failure.message)), (
      galleries,
    ) {
      if (galleries.isEmpty) {
        emit(const NewsEmpty());
        return;
      }

      emit(NewsLoaded(galleries: galleries));
    });
  }
}
