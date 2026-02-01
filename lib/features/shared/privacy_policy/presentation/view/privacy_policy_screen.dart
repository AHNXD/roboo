import 'package:flutter/material.dart';

import '../../../../../core/utils/app_localizations.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/custom_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String routeName = '/privacy-policy';
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'app_title_privacy'.tr(context)),
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
                  Text(
                    'privacy_welcome'.tr(context),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColors,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildParagraph(context, 'privacy_intro'.tr(context)),
                  const Divider(height: 40, color: Colors.grey),

                  _buildSectionHeader(context, 'privacy_header_1'),
                  _buildListItem(context, 'privacy_list_1a'),
                  _buildListItem(context, 'privacy_list_1b'),

                  _buildSectionHeader(context, 'privacy_header_2'),
                  _buildListItem(context, 'privacy_list_2a'),
                  _buildListItem(context, 'privacy_list_2b'),
                  _buildListItem(context, 'privacy_list_2c'),
                  _buildListItem(context, 'privacy_list_2b'),
                  _buildListItem(context, 'privacy_list_2c'),

                  _buildSectionHeader(context, 'privacy_header_3'),
                  _buildListItem(context, 'privacy_list_3a'),
                  _buildListItem(context, 'privacy_list_3b'),
                  _buildListItem(context, 'privacy_list_3c'),

                  _buildSectionHeader(context, 'privacy_header_4'),
                  _buildListItem(context, 'privacy_content_4'),

                  _buildSectionHeader(context, 'privacy_header_5'),
                  _buildListItem(context, 'privacy_list_5a'),
                  _buildListItem(context, 'privacy_list_5b'),

                  _buildSectionHeader(context, 'privacy_header_6'),
                  _buildListItem(context, 'privacy_content_6'),

                  _buildSectionHeader(context, 'privacy_header_7'),
                  _buildParagraph(context, 'privacy_content_7'.tr(context)),

                  const Divider(height: 40, color: Colors.grey),

                  Text(
                    'privacy_last_updated'.tr(context),
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 8),
      child: Text(
        key.tr(context),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
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

  Widget _buildListItem(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '• ',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.primaryColors,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              key.tr(context),
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
