import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/pagination_model.dart';
import '../../../../../../core/utils/safe_emit.dart';
import '../../../data/models/faq_model.dart';
import '../../../data/repos/faq_repo.dart';

part 'faq_state.dart';

class FaqCubit extends Cubit<FaqState> with SafeEmit<FaqState> {
  final FaqRepo _faqRepo;

  FaqCubit(this._faqRepo) : super(FaqInitial());

  List<FaqModel> _faqs = const [];
  PaginationModel _pagination = PaginationModel.single;
  bool _isLoadingMore = false;

  Future<void> getFaqs() async {
    safeEmit(FaqLoading());
    final result = await _faqRepo.getFaqs();
    result.fold((failure) => safeEmit(FaqError(errorMsg: failure.message)), (
      page,
    ) {
      _faqs = page.items;
      _pagination = page.pagination;
      safeEmit(
        _faqs.isEmpty
            ? FaqEmpty()
            : FaqLoaded(faqs: _faqs, hasMore: page.hasMore),
      );
    });
  }

  /// Appends the next page. A failure leaves the answers already on screen.
  Future<void> loadMoreFaqs() async {
    if (_isLoadingMore || !_pagination.hasMore) return;

    _isLoadingMore = true;
    safeEmit(FaqLoaded(faqs: _faqs, hasMore: true, isLoadingMore: true));

    final result = await _faqRepo.getFaqs(page: _pagination.nextPage);

    _isLoadingMore = false;

    result.fold(
      (_) => safeEmit(FaqLoaded(faqs: _faqs, hasMore: _pagination.hasMore)),
      (page) {
        _faqs = [..._faqs, ...page.items];
        _pagination = page.pagination;
        safeEmit(FaqLoaded(faqs: _faqs, hasMore: page.hasMore));
      },
    );
  }
}
