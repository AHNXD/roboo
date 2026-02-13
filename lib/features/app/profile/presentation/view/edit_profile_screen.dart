import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/custom_field_lable.dart';
import 'package:roboo/core/widgets/gender_selector_row_widget.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/profile/presentation/view/widgets/editable_profile_avatar_widget.dart';
import 'package:roboo/features/app/profile/presentation/view/widgets/interests_list_widget.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: "سارة",
  );
  final TextEditingController _dateController = TextEditingController(
    text: "19/10/2015",
  );
  final TextEditingController _emailController = TextEditingController(
    text: "sara@gmail.com",
  );

  String _selectedGender = "female";
  final List<String> _selectedInterests = ["programming", "robotics"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "profile_title".tr(context)),

      // 1. Move the button here to keep it persistently at the bottom
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
          child: PrimaryButton(
            text: "save_changes".tr(context),
            enterButton: true,
            backgroundColor: AppColors.primaryColors,
            mainColor: AppColors.primaryTwoColors,
            onTap: () {
              // Handle Save Logic
            },
          ),
        ),
      ),

      // 2. The rest of your content stays scrollable
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 1. Avatar
              ProfileAvatarEdit(
                imagePath: AssetsData.profile,
                onEdit: () {
                  // Handle image pick
                },
              ),

              const SizedBox(height: 30),

              // 2. Name
              buildLabel("what_is_your_name".tr(context)),
              CustomTextField(
                hintText: "name_hint".tr(context),
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),

              const SizedBox(height: 20),

              // 3. Date
              buildLabel("birth_date".tr(context)),
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
                      _dateController.text = "${pickedDate.toLocal()}".split(
                        ' ',
                      )[0];
                    });
                  }
                },
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: _dateController,
                    hintText: "birth_date".tr(context),
                    suffixIcon: Icons.calendar_today_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 4. Email
              buildLabel("email".tr(context)),
              CustomTextField(
                hintText: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              // 5. Gender
              buildLabel("gender_question".tr(context)),
              GenderSelector(
                selectedGender: _selectedGender,
                onSelect: (val) => setState(() => _selectedGender = val),
              ),

              const SizedBox(height: 20),

              // 6. Interests
              buildLabel("interests_question".tr(context)),
              InterestsSelector(
                selectedInterests: _selectedInterests,
                onToggle: _toggleInterest,
              ),

              // Removed the button from here
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleInterest(String key) {
    setState(() {
      if (_selectedInterests.contains(key)) {
        _selectedInterests.remove(key);
      } else {
        _selectedInterests.add(key);
      }
    });
  }
}
