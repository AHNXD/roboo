import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_3d_btn.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/go_to_button.dart';
import 'package:roboo/features/app/profile/presentation/view/widgets/profile_header_widget.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/forget_password_screen.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'edit_profile_screen.dart';
import '../../../my-courses/presentation/view/my_courses_screen.dart';

class ProfileMenuScreen extends StatelessWidget {
  static const String routeName = '/profile-menu';

  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              offset: Offset(0, -1),
              blurRadius: 10,
            ),
          ],
          color: Colors.white,
        ),
        child: SafeArea(
          child: Custom3DButton(
            text: "delete_account".tr(context),
            iconData: Icons.delete,
            onTap: () {},
          ),
        ),
      ),
      appBar: CustomAppbar(title: "profile_title".tr(context)),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            const ProfileHeader(
              name: "سارة",
              points: 1400,
              imagePath: AssetsData.profile,
            ),

            const SizedBox(height: 40),

            // 2. Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  GoToButton(
                    title: "personal_info".tr(context),
                    image: AssetsData.myProfile,
                    onTap: () => Navigator.pushNamed(
                      context,
                      EditProfileScreen.routeName,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoToButton(
                    title: "my_courses_title".tr(context),
                    image: AssetsData.myCourses,
                    onTap: () =>
                        Navigator.pushNamed(context, MyCoursesScreen.routeName),
                  ),
                  const SizedBox(height: 16),
                  GoToButton(
                    title: "change_password".tr(context),
                    image: AssetsData.changePassword,
                    onTap: () => Navigator.pushNamed(
                      context,
                      ForgotPasswordScreen.routeName,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 3. Delete Button
          ],
        ),
      ),
    );
  }
}
