import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/features/temp/data/repos/temp_repo.dart';

part 'temp_state.dart';

class TempCubit extends Cubit<TempState> {
  TempCubit(this._tempRepo) : super(TempInitial());

  final TempRepo _tempRepo;

  Future temoFunction() async {
    emit(TempLoading());
    var data = await _tempRepo.tempFunction();
    data.fold((failure) => emit(TempError(errorMsg: failure.message)), (user) {
      emit(TempSuccess());
    });
  }
}
