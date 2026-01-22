import 'package:flutter/material.dart';

import '../../../../../core/utils/app_localizations.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/custom_appbar.dart';

class AboutUsScreen extends StatelessWidget {
  static const String routeName = '/about-us';
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'app_title_about'.tr(context)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'app_title_about'.tr(context),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'A brief subtitle about your app\'s purpose.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const Divider(height: 50, color: Colors.grey),

            _buildInfoCard(
              context,
              icon: Icons.lightbulb_outline,
              headerKey: 'about_header_mission',
              contentKey: 'about_content_mission',
            ),
            const SizedBox(height: 25),

            _buildInfoCard(
              context,
              icon: Icons.groups_outlined,
              headerKey: 'about_header_team',
              contentKey: 'about_content_team',
            ),
            const SizedBox(height: 25),

            _buildInfoCard(
              context,
              icon: Icons.visibility_outlined,
              headerKey: 'about_header_vision',
              contentKey: 'about_content_vision',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String headerKey,
    required String contentKey,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColors.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: AppColors.primaryColors),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerKey.tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  contentKey.tr(context),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
