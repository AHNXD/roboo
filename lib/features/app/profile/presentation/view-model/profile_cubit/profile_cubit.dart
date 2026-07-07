import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/profile_model.dart';
import '../../../data/repos/profile_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo;

  ProfileCubit(this._profileRepo) : super(ProfileInitial());

  Future<void> getProfile() async {
    emit(ProfileLoading());
    final result = await _profileRepo.getProfile();
    result.fold(
      (failure) => emit(ProfileError(errorMsg: failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> updateProfile({
    required String name,
    required String nameAr,
    required String birthdate,
    required String gender,
    required String language,
    required List<String> heardAbout,
    String? fcmToken,
    String? imagePath,
    String? imageName,
  }) async {
    emit(ProfileSubmitting());
    final result = await _profileRepo.updateProfile(
      name: name,
      nameAr: nameAr,
      birthdate: birthdate,
      gender: gender,
      language: language,
      heardAbout: heardAbout,
      fcmToken: fcmToken,
      imagePath: imagePath,
      imageName: imageName,
    );
    result.fold(
      (failure) => emit(ProfileError(errorMsg: failure.message)),
      (profile) => emit(ProfileUpdateSuccess(profile: profile)),
    );
  }
}
