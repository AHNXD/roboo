import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_localizations.dart';
import '../../../../../core/utils/services_locater.dart';
import '../../../../../core/widgets/custom_appbar.dart';
import '../../../../../core/widgets/status_display_widget.dart';
import '../view-model/legal_content_cubit/legal_content_cubit.dart';
import 'widgets/legal_html_content_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String routeName = '/privacy-policy';
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalContentScreen(
      title: "privacy_policy_title".tr(context),
      emptyMessage: "privacy_policy_empty".tr(context),
      onLoad: (cubit) => cubit.getPrivacyPolicy(),
    );
  }
}

class LegalContentScreen extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final Future<void> Function(LegalContentCubit cubit) onLoad;

  const LegalContentScreen({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = LegalContentCubit(getit.get());
        onLoad(cubit);
        return cubit;
      },
      child: Scaffold(
        appBar: CustomAppbar(title: title),
        body: SafeArea(
          child: BlocBuilder<LegalContentCubit, LegalContentState>(
            builder: (context, state) {
              return switch (state) {
                LegalContentInitial() ||
                LegalContentLoading() => StatusDisplayWidget(
                  message: "wait".tr(context),
                  withAnimation: true,
                ),
                LegalContentEmpty() => StatusDisplayWidget(
                  message: emptyMessage,
                ),
                LegalContentError(:final errorMsg) => StatusDisplayWidget(
                  message: errorMsg.tr(context),
                ),
                LegalContentLoaded(:final content) => RefreshIndicator(
                  onRefresh: () => onLoad(context.read<LegalContentCubit>()),
                  child: LegalHtmlContentWidget(
                    html: content.bodyFor(
                      Localizations.localeOf(context).languageCode,
                    ),
                    updatedAt: content.updatedAt,
                    updatedAtLabel: "last_updated".tr(context),
                  ),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}
