import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_3d_btn.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';

import 'package:hexagon/hexagon.dart';
import 'package:roboo/core/widgets/go_to_button.dart';
import 'package:roboo/features/auth/presentation/views/forget-password/presentation/view/forget_password_screen.dart';

import 'edit_profile_screen.dart';
import 'my_courses_screen.dart';

class ProfileMenuScreen extends StatelessWidget {
  static const String routeName = '/profile-menu';

  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "الملف الشخصي"),
      body: SafeArea(
        child: Column(
          children: [
            HexagonWidget.flat(
              width: 110,
              color: AppColors.primaryColors,
              padding: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(AssetsData.profile, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "سارة",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "1400 نقطة",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColors.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 40),

            // 3. Menu Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  GoToButton(
                    title: "المعلومات الشخصية",
                    image: AssetsData.myProfile,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoToButton(
                    title: "دوراتي",
                    image: AssetsData.myCourses,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const MyCoursesScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoToButton(
                    title: "تغيير كلمة المرور",
                    image: AssetsData.changePassword,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const ForgotPasswordScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Custom3DButton(
                text: "حذف الحساب",
                iconData: Icons.delete,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
