import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/shared/complaints/presentation/view/widgets/header_text_widget.dart';
import 'package:roboo/features/shared/complaints/presentation/view/widgets/input_field_widget.dart';
import 'package:roboo/features/shared/complaints/presentation/view/widgets/rating_row_widget.dart';

class ComplaintsScreen extends StatelessWidget {
  static const String routeName = '/complaints';
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "complaints_title".tr(context)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. Description Text
              const ComplaintsHeader(),

              const SizedBox(height: 20),

              // 2. Rating Section
              const ComplaintsRatingRow(profileImage: AssetsData.profile),

              const SizedBox(height: 30),

              // 3. Text Input Area
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: ComplaintInputField(),
              ),

              const SizedBox(height: 30),

              // 4. Send Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: PrimaryButton(
                  text: "send".tr(context), // Localized Key
                  backgroundColor: AppColors.primaryColors,
                  mainColor: AppColors.primaryTwoColors,
                  imagePath: AssetsData.forwardButton,
                  onTap: () {
                    // Handle submission logic
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Feedback Sent!"),
                      ), // Localize this too ideally
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
