import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/shared/faq/data/models/faq_model.dart';
import 'package:roboo/features/shared/faq/presentation/view-model/faq_cubit/faq_cubit.dart';
import 'package:roboo/features/shared/faq/presentation/view/widgets/faq_tile_widget.dart';

class FaqScreen extends StatelessWidget {
  static const String routeName = '/faq';
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FaqCubit(getit.get())..getFaqs(),
      child: Scaffold(
        appBar: CustomAppbar(title: "faq_title".tr(context)),
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: DotBackground()),
              BlocBuilder<FaqCubit, FaqState>(
                builder: (context, state) {
                  return switch (state) {
                    FaqLoading() || FaqInitial() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    FaqEmpty() => StatusDisplayWidget(
                      message: "no_faqs_found".tr(context),
                    ),
                    FaqError(:final errorMsg) => StatusDisplayWidget(
                      message: errorMsg.tr(context),
                    ),
                    FaqLoaded(:final faqs) => _FaqList(faqs: faqs),
                  };
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  final List<FaqModel> faqs;

  const _FaqList({required this.faqs});

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final item = faqs[index];
        return FaqTile(
          question: item.titleFor(languageCode),
          answer: item.descriptionFor(languageCode),
          isExpanded: index == 0,
        );
      },
    );
  }
}
