import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/utils/cache_helper.dart';
import '../../../data/repos/token_repo/token_repo.dart';

part 'token_state.dart';

class TokenCubit extends Cubit<TokenState> {
  final TokenRepo _tokenRepo;
  TokenCubit(this._tokenRepo) : super(TokenInitial());

  Future cheackToken() async {
    emit(TokenLoadingState());

    bool isFirstUse = CacheHelper.getData(key: 'firstTime') ?? true;
    if (isFirstUse) {
      emit(IsFirstUseTrue());
    } else {
      String? token = CacheHelper.getData(key: 'token');
      if (token == null) {
        emit(IsNotVaildToken());
      } else {
        var resp = await _tokenRepo.cheackToken();
        resp.fold(
          (failure) {
            emit(TokenErrorState(failure.message));
          },
          (user) {
            emit(IsVaildToken());
          },
        );
      }
    }
  }
}
