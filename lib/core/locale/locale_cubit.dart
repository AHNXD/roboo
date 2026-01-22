import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../utils/cache_helper.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<ChangeLocaleState> {
  LocaleCubit() : super(ChangeLocaleState(locale: const Locale("en")));

  Future<void> getSaveLanguage() async {
    final String cachedLanguageCode = CacheHelper.getData(
      key: "LOCALE",
    ).toString();

    emit(ChangeLocaleState(locale: Locale(cachedLanguageCode)));
  }

  Future<void> changeLanguage(String languageCode) async {
    await CacheHelper.setString(key: "LOCALE", value: languageCode);

    emit(ChangeLocaleState(locale: Locale(languageCode)));
  }
}
