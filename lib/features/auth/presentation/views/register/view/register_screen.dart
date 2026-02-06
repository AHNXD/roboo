import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_field_lable.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/gender_selector_row_widget.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/auth/presentation/views/register/view/widgets/source_selector_widget.dart';
import '../../../../../../core/widgets/custome_text_field.dart';
import '../../widgets/auth_footer_widget.dart';
import '../../widgets/auth_header_widget.dart';

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

  // Date Picker Logic
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  // Source Toggle Logic
  void _toggleSource(String key) {
    setState(() {
      if (_selectedSources.contains(key)) {
        _selectedSources.remove(key);
      } else {
        _selectedSources.add(key);
      }
    });
  }

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

                  // Header (Reused)
                  const AuthHeader(),

                  const SizedBox(height: 20),

                  // Robot Message
                  Hero(
                    tag: 'message_bubble',
                    child: RobotMessageBubble(
                      message: "register_welcome".tr(context),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Personal Info Section ---

                        // Name
                        buildLabel("what_is_your_name".tr(context)),
                        CustomTextField(
                          hintText: "name_hint".tr(context),
                          keyboardType: TextInputType.name,
                        ),

                        const SizedBox(height: 20),

                        // Date
                        buildLabel("birth_date".tr(context)),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: CustomTextField(
                              controller: _dateController,
                              hintText: "birth_date".tr(context),
                              suffixIcon: Icons.calendar_today_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Gender
                        buildLabel("gender_question".tr(context)),
                        GenderSelector(
                          selectedGender: _selectedGender,
                          onSelect: (val) =>
                              setState(() => _selectedGender = val),
                        ),

                        const SizedBox(height: 20),

                        // --- Sources Section ---
                        buildLabel("where_know_roboo".tr(context)),
                        RegisterSourceSelector(
                          selectedSources: _selectedSources,
                          onToggle: _toggleSource,
                        ),

                        const SizedBox(height: 30),

                        // --- Credentials Section ---
                        buildLabel("enter_credentials".tr(context)),
                        const SizedBox(height: 10),

                        CustomTextField(
                          hintText: "email_hint".tr(context),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          hintText: "password_hint".tr(context),
                          obscureText: true,
                          suffixIcon: Icons.visibility_off_outlined,
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          hintText: "confirm_password".tr(context),
                          obscureText: true,
                          suffixIcon: Icons.visibility_off_outlined,
                        ),

                        const SizedBox(height: 30),

                        // --- Submit Button ---
                        PrimaryButton(
                          text: "next".tr(context),
                          imagePath: AssetsData.forwardButton,
                          backgroundColor: AppColors.primaryColors,
                          mainColor: AppColors.primaryTwoColors,
                          onTap: () {
                            // Handle Register Logic
                          },
                        ),

                        const SizedBox(height: 20),

                        // --- Footer ---
                        AuthFooter(
                          text: "have_account".tr(context),
                          actionText: "login_now".tr(context),
                          onTap: () => Navigator.pop(context),
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
}
