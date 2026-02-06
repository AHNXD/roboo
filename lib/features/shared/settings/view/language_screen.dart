import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/custom_option_button.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import '../../../../core/locale/locale_cubit.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, ChangeLocaleState>(
      builder: (context, state) {
        final String currentLang = state.locale.languageCode;

        return Scaffold(
          appBar: CustomAppbar(
            title: "language".tr(context),
          ), // Localized Title
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                children: [
                  CustomOptionButton(
                    text: "${"language_arabic".tr(context)} 🇸🇾",
                    isRadio: true,
                    isSelected: currentLang == 'ar',
                    onTap: () {
                      context.read<LocaleCubit>().changeLanguage('ar');
                    },
                  ),

                  const SizedBox(height: 16),

                  CustomOptionButton(
                    text: "${"language_english".tr(context)} 🇺🇸",
                    isRadio: true,
                    isSelected: currentLang == 'en',
                    onTap: () {
                      context.read<LocaleCubit>().changeLanguage('en');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
