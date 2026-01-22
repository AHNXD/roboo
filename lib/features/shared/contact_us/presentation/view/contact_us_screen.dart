import 'package:flutter/material.dart';


import '../../../../../core/utils/app_localizations.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/widgets/custom_appbar.dart';

class ContactUsScreen extends StatelessWidget {
  static const String routeName = '/contact-us';
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'app_title_contact'.tr(context)),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'contact_welcome'.tr(context),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryColors,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'contact_intro'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const Divider(height: 50, color: Colors.grey),

                  // --- Customer Support Card ---
                  _buildContactTile(
                    context,
                    icon: Icons.support_agent,
                    titleKey: 'contact_sub_support',
                    descriptionKey: 'contact_desc_support',
                    contactDetailKey: 'contact_email_support',
                    onTap: () {},
                    // _launchEmail('contact_email_support'.tr(context)),
                  ),
                  const SizedBox(height: 20),

                  // --- Media & Press Card ---
                  _buildContactTile(
                    context,
                    icon: Icons.camera_roll_outlined,
                    titleKey: 'contact_sub_media',
                    descriptionKey: 'contact_desc_media',
                    contactDetailKey: 'contact_email_media',
                    onTap: () {},
                    // _launchEmail('contact_email_media'.tr(context)),
                  ),
                  const SizedBox(height: 30),

                  // --- Address ---
                  _buildAddressSection(context),
                ],
              ),
            ),
          ),
          // --- CALL TO ACTION (Fixed Bottom Bar) ---
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                // _launchEmail('contact_email_support'.tr(context)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColors,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'contact_call_to_action'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    required String descriptionKey,
    required String contactDetailKey,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(10),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      leading: Icon(icon, size: 35, color: AppColors.primaryColors),
      title: Text(
        titleKey.tr(context),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            descriptionKey.tr(context),
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            contactDetailKey.tr(context),
            style: TextStyle(
              color: AppColors.primaryColors,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black38,
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'contact_sub_address'.tr(context),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.location_on_outlined,
            color: AppColors.primaryColors,
          ),
          title: Text(
            'contact_address_line1'.tr(context),
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          subtitle: Text(
            'contact_address_line2'.tr(context),
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
