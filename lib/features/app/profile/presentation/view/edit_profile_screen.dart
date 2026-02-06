import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/custom_field_lable.dart';
import 'package:roboo/core/widgets/custom_option_button.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:hexagon/hexagon.dart';

import '../../../../../core/widgets/custome_text_field.dart';

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
      appBar: CustomAppbar(title: "الملف الشخصي"),
      body: SafeArea(
        child: Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Avatar with Edit Icon
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      HexagonWidget.flat(
                        width: 100,
                        color: AppColors.primaryColors,
                        padding: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            AssetsData.profile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColors,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.file_upload_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- Name Input ---
                buildLabel("ما اسمك؟"),
                CustomTextField(
                  hintText: "الاسم",
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 20),

                // --- Date Input ---
                buildLabel("تاريخ الولادة"),
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
                      hintText: "تاريخ الولادة",
                      suffixIcon: Icons.calendar_today_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                buildLabel("البريد الإلكتروني"),

                CustomTextField(
                  hintText: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                buildLabel("هل أنت ذكر أم أنثى؟"),
                Row(
                  children: [
                    Expanded(
                      child: CustomOptionButton(
                        text: "أنثى",
                        image: AssetsData.female,
                        isRadio: true,
                        isSelected: _selectedGender == "female",
                        onTap: () => setState(() => _selectedGender = "female"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomOptionButton(
                        text: "ذكر",
                        image: AssetsData.male,
                        isRadio: true,
                        isSelected: _selectedGender == "male",
                        onTap: () => setState(() => _selectedGender = "male"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                buildLabel("ماذا تريد ان تتعلم؟"),
                CustomOptionButton(
                  text: "البرمجة",
                  image: AssetsData.programming,
                  isRadio: false,
                  isSelected: _selectedInterests.contains("programming"),
                  onTap: () => _toggleInterest("programming"),
                ),
                CustomOptionButton(
                  text: "الروبوتيك",
                  image: AssetsData.robotic,
                  isRadio: false,
                  isSelected: _selectedInterests.contains("robotics"),
                  onTap: () => _toggleInterest("robotics"),
                ),
                CustomOptionButton(
                  text: "الذكاء الاصطناعي",
                  image: AssetsData.ai,
                  isRadio: false,
                  isSelected: _selectedInterests.contains("ai"),
                  onTap: () => _toggleInterest("ai"),
                ),

                const SizedBox(height: 30),

                PrimaryButton(
                  text: "تعديل",
                  imagePath: AssetsData.forwardButton,
                  backgroundColor: AppColors.primaryColors,
                  mainColor: AppColors.primaryTwoColors,
                  onTap: () {},
                ),

                const SizedBox(height: 40),
              ],
            ),
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
