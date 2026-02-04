import 'package:flutter/material.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/primary_button.dart';

import '../../../../app/leaderboard/presentation/view/leaderboard_screen.dart';

class ComplaintsScreen extends StatelessWidget {
  static const String routeName = '/complaints';
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "الشكاوى والاقتراحات"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "يهمنا رأيك!\nقيّم تجربتك معنا و أخبرنا باقتراحاتك أو إذا واجهت أي مشكلة لا تتردد في تقديم شكوى لنا.\nاكتب شكواك أو اقتراحك و سوف نقوم بمراجعتها!",
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(height: 1.6),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HexagonProfileAvatar(imagePath: AssetsData.profile, size: 60),
                  const SizedBox(width: 20),
                  Row(
                    children: List.generate(
                      4,
                      (index) => const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFCA28),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Text Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryColors.withOpacity(0.3),
                    ),
                  ),
                  child: const TextField(
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: "أرسل ملاحظاتك",
                      hintStyle: TextStyle(color: Colors.black26),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Send Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: PrimaryButton(
                  text: "إرسال",
                  backgroundColor: AppColors.primaryColors,
                  mainColor: AppColors.primaryTwoColors,
                  imagePath: AssetsData.forwardButton,
                  onTap: () {},
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
