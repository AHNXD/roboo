import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';

import '../../../../../../core/widgets/custom_option_button.dart';
import '../../../../../../core/widgets/custome_text_field.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _dateController = TextEditingController();
  String _selectedGender = "";
  final List<String> _selectedSources = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Background
            const Positioned.fill(child: DotBackground()),

            // 2. Scrollable Form
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // --- Header ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Hero(
                            tag: 'logo',
                            child: Image.asset(
                              AssetsData.logo,
                              width: MediaQuery.of(context).size.width * 0.25,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: CustomBackButton(
                              onTap: () => Navigator.pop(context),
                              isWhite: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Robot Message ---
                  Hero(
                    tag: 'message_bubble',
                    child: const RobotMessageBubble(
                      message:
                          "أهلاً بك في عالم Roboo. لنبدأ معاً رحلة تعلم ممتعة!",
                    ),
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Name Input ---
                        _buildLabel("ما اسمك؟"),
                        const CustomTextField(
                          hintText: "الاسم",
                          keyboardType: TextInputType.name,
                        ),

                        const SizedBox(height: 20),

                        // --- Date Input ---
                        _buildLabel("تاريخ الولادة"),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dateController.text = "${pickedDate.toLocal()}"
                                    .split(' ')[0];
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: _dateController,
                              hintText: "تاريخ الولادة",
                              suffixIcon: Icons.calendar_today_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildLabel("هل أنت ذكر أم أنثى؟"),
                        Row(
                          children: [
                            Expanded(
                              child: CustomOptionButton(
                                text: "أنثى",
                                image: AssetsData.female,
                                isRadio: true,
                                isSelected: _selectedGender == "female",
                                onTap: () =>
                                    setState(() => _selectedGender = "female"),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomOptionButton(
                                text: "ذكر",
                                image: AssetsData.male,
                                isRadio: true,
                                isSelected: _selectedGender == "male",
                                onTap: () =>
                                    setState(() => _selectedGender = "male"),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // --- "Where do you know Roboo" (Checkbox Style) ---
                        _buildLabel("من أين تعرف Roboo؟"),
                        CustomOptionButton(
                          text: "التواصل الاجتماعي",
                          image: AssetsData.socialMedia,
                          isRadio: false,
                          isSelected: _selectedSources.contains("social"),
                          onTap: () => _toggleSource("social"),
                        ),
                        CustomOptionButton(
                          text: "العائلة",
                          image: AssetsData.family,
                          isRadio: false,
                          isSelected: _selectedSources.contains("family"),
                          onTap: () => _toggleSource("family"),
                        ),
                        CustomOptionButton(
                          text: "الأصدقاء",
                          image: AssetsData.friends,
                          isRadio: false,
                          isSelected: _selectedSources.contains("friends"),
                          onTap: () => _toggleSource("friends"),
                        ),
                        CustomOptionButton(
                          text: "المدرسة",
                          image: AssetsData.school,
                          isRadio: false,
                          isSelected: _selectedSources.contains("school"),
                          onTap: () => _toggleSource("school"),
                        ),
                        CustomOptionButton(
                          text: "المسابقات",
                          image: AssetsData.events,
                          isRadio: false,
                          isSelected: _selectedSources.contains("events"),
                          onTap: () => _toggleSource("events"),
                        ),

                        const SizedBox(height: 30),

                        // --- Auth Fields Header ---
                        _buildLabel("أدخل البريد الإلكتروني و كلمة المرور"),
                        const SizedBox(height: 10),

                        const CustomTextField(hintText: "Email"),
                        const SizedBox(height: 12),
                        const CustomTextField(
                          hintText: "Password",
                          obscureText: true,
                          suffixIcon: Icons.visibility_off_outlined,
                        ),
                        const SizedBox(height: 12),
                        const CustomTextField(
                          hintText: "Confirm Password",
                          obscureText: true,
                          suffixIcon: Icons.visibility_off_outlined,
                        ),

                        const SizedBox(height: 30),

                        // --- Submit Button ---
                        // Using your Custom3DButton style here
                        PrimaryButton(
                          text: "التالي",
                          imagePath: AssetsData
                              .forwardButton, // Assuming you have an arrow icon
                          backgroundColor: AppColors.primaryColors,
                          mainColor: AppColors.primaryTwoColors,
                          onTap: () {
                            // Handle Register Logic
                          },
                        ),

                        const SizedBox(height: 20),

                        // --- Footer Text ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "لدى حساب بالفعل؟",
                              style: TextStyle(
                                color: AppColors.primaryColors.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                "سجل دخول الآن",
                                style: TextStyle(
                                  color: AppColors.primaryColors,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for toggle logic
  void _toggleSource(String key) {
    setState(() {
      if (_selectedSources.contains(key)) {
        _selectedSources.remove(key);
      } else {
        _selectedSources.add(key);
      }
    });
  }

  // Helper for Label Text
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
