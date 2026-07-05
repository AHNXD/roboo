import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/faq_model.dart';
import '../../../data/repos/faq_repo.dart';

part 'faq_state.dart';

class FaqCubit extends Cubit<FaqState> {
  final FaqRepo _faqRepo;

  FaqCubit(this._faqRepo) : super(FaqInitial());

  Future<void> getFaqs() async {
    emit(FaqLoading());
    final result = await _faqRepo.getFaqs();
    result.fold(
      (failure) => emit(FaqError(errorMsg: failure.message)),
      (faqs) => faqs.isEmpty ? emit(FaqEmpty()) : emit(FaqLoaded(faqs: faqs)),
    );
  }
}
