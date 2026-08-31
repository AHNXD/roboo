import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';
import '../../../data/models/news_gallery_model.dart';
import '../../../data/repos/news_repo.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> with SafeEmit<NewsState> {
  final NewsRepo _newsRepo;

  NewsCubit(this._newsRepo) : super(const NewsInitial());

  List<NewsGalleryModel> _galleries = const [];
  PaginationModel _pagination = PaginationModel.single;
  bool _isLoadingMore = false;

  Future<void> getGalleries() async {
    safeEmit(const NewsLoading());

    final result = await _newsRepo.getGalleries();
    result.fold((failure) => safeEmit(NewsError(errorMsg: failure.message)), (
      page,
    ) {
      _galleries = page.items;
      _pagination = page.pagination;

      if (_galleries.isEmpty) {
        safeEmit(const NewsEmpty());
        return;
      }

      safeEmit(NewsLoaded(galleries: _galleries, hasMore: page.hasMore));
    });
  }

  /// Appends the next page. A failure leaves what is already on screen alone;
  /// scrolling again retries.
  Future<void> loadMoreGalleries() async {
    if (_isLoadingMore || !_pagination.hasMore) return;

    _isLoadingMore = true;
    safeEmit(
      NewsLoaded(galleries: _galleries, hasMore: true, isLoadingMore: true),
    );

    final result = await _newsRepo.getGalleries(page: _pagination.nextPage);

    _isLoadingMore = false;

    result.fold(
      (_) => safeEmit(
        NewsLoaded(galleries: _galleries, hasMore: _pagination.hasMore),
      ),
      (page) {
        _galleries = [..._galleries, ...page.items];
        _pagination = page.pagination;
        safeEmit(NewsLoaded(galleries: _galleries, hasMore: page.hasMore));
      },
    );
  }
}
