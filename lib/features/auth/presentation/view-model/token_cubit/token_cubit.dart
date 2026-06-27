import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/constats.dart';
import '../../../data/repos/token_repo/token_repo.dart';

part 'token_state.dart';

class TokenCubit extends Cubit<TokenState> {
  final TokenRepo _tokenRepo;
  TokenCubit(this._tokenRepo) : super(TokenInitial());

  Future<void> cheackToken() async {
    emit(TokenLoadingState());

    final token = CacheHelper.getData(key: 'token')?.toString();
    if (token == null || token.isEmpty) {
      isGuest = true;
      emit(IsNotVaildToken());
    } else {
      final resp = await _tokenRepo.cheackToken();
      resp.fold(
        (failure) async {
          await CacheHelper.removeData(key: 'token');
          await CacheHelper.removeData(key: 'user');
          isGuest = true;
          emit(IsNotVaildToken());
        },
        (user) {
          isGuest = false;
          emit(IsVaildToken());
        },
      );
    }
  }
}
