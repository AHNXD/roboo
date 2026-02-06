import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/shared/faq/presentation/view/widgets/faq_tile_widget.dart';

class FaqScreen extends StatelessWidget {
  static const String routeName = '/faq';
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> faqs = [
      {'q': "faq_q1", 'a': "faq_a1", 'expanded': true},
      {'q': "faq_q2", 'a': "faq_a2", 'expanded': false},
      {'q': "faq_q3", 'a': "faq_a3", 'expanded': false},
      {'q': "faq_q4", 'a': "faq_a4", 'expanded': false},
    ];

    return Scaffold(
      appBar: CustomAppbar(title: "faq_title".tr(context)),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: DotBackground()),

            Column(
              children: [
                Expanded(
                  child: faqs.isEmpty
                      ? StatusDisplayWidget(
                          message: "no_faqs_found".tr(context),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          itemCount: faqs.length,
                          itemBuilder: (context, index) {
                            final item = faqs[index];
                            return FaqTile(
                              question: (item['q'] as String).tr(context),
                              answer: (item['a'] as String).tr(context),
                              isExpanded: item['expanded'] as bool,
                            );
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
