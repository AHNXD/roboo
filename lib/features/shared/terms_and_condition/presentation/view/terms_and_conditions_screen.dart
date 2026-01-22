import 'package:flutter/material.dart';

import '../../../../../core/utils/app_localizations.dart';
import '../../../../../core/widgets/custom_appbar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  static const String routeName = '/terms-and-conditions';
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'app_title_terms'.tr(context)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildNoticeBanner(
                    context,
                    'notice_important'.tr(context),
                    Colors.red.shade700,
                  ),
                  const SizedBox(height: 15),
                  _buildParagraph(context, 'terms_intro'.tr(context)),
                  const Divider(height: 40, color: Colors.grey),

                  _buildSection(context, 'terms_header_1', 'terms_content_1'),
                  _buildSection(context, 'terms_header_2', 'terms_content_2a'),
                  _buildParagraph(context, 'terms_content_2b'.tr(context)),
                  _buildSection(context, 'terms_header_3', 'terms_content_3a'),
                  _buildParagraph(context, 'terms_content_3b'.tr(context)),
                  _buildSection(context, 'terms_header_4', 'terms_content_4'),
                  _buildSection(context, 'terms_header_5', 'terms_content_5a'),
                  _buildParagraph(context, 'terms_content_5b'.tr(context)),
                  _buildSection(context, 'terms_header_6', 'terms_content_6'),
                  _buildSection(context, 'terms_header_7', 'terms_content_7'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBanner(BuildContext context, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String headerKey,
    String contentKey,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 5),
          child: Text(
            headerKey.tr(context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        _buildParagraph(context, contentKey.tr(context)),
      ],
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: Colors.black54,
        ),
      ),
    );
  }
}
