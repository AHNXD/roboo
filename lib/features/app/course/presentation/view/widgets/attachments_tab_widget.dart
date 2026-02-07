import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';

class CourseAttachmentsTab extends StatelessWidget {
  const CourseAttachmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          "links".tr(context),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text("link_title_example".tr(context)),
          trailing: const Icon(Icons.link, color: AppColors.primaryColors),
          onTap: () {},
        ),
        const Divider(),
        Text(
          "files".tr(context),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text("file_title_example".tr(context)),
          trailing: const Icon(
            Icons.file_present,
            color: AppColors.primaryColors,
          ),
          onTap: () {},
        ),
      ],
    );
  }
}
