import 'package:flutter/material.dart';

import '../../../../../core/utils/app_localizations.dart';
import '../view-model/legal_content_cubit/legal_content_cubit.dart';
import 'privacy_policy_screen.dart';

class TermsOfUseScreen extends StatelessWidget {
  static const String routeName = '/terms-of-use';
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalContentScreen(
      title: "terms_of_use_title".tr(context),
      emptyMessage: "terms_of_use_empty".tr(context),
      onLoad: (LegalContentCubit cubit) => cubit.getTermsOfUse(),
    );
  }
}
