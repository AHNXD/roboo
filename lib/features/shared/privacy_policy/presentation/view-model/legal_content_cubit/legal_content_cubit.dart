import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/legal_content_model.dart';
import '../../../data/repos/legal_content_repo.dart';

part 'legal_content_state.dart';

class LegalContentCubit extends Cubit<LegalContentState> {
  final LegalContentRepo _legalContentRepo;

  LegalContentCubit(this._legalContentRepo) : super(LegalContentInitial());

  Future<void> getPrivacyPolicy() async {
    emit(LegalContentLoading());
    final result = await _legalContentRepo.getPrivacyPolicy();
    result.fold(
      (failure) => emit(LegalContentError(errorMsg: failure.message)),
      _emitLoadedOrEmpty,
    );
  }

  Future<void> getTermsOfUse() async {
    emit(LegalContentLoading());
    final result = await _legalContentRepo.getTermsOfUse();
    result.fold(
      (failure) => emit(LegalContentError(errorMsg: failure.message)),
      _emitLoadedOrEmpty,
    );
  }

  void _emitLoadedOrEmpty(LegalContentModel content) {
    if ((content.bodyEn?.trim().isEmpty ?? true) &&
        (content.bodyAr?.trim().isEmpty ?? true)) {
      emit(LegalContentEmpty());
      return;
    }

    emit(LegalContentLoaded(content: content));
  }
}
