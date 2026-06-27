import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/cache_helper.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/enums.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/utils/validation.dart';
import 'package:roboo/core/widgets/custom_field_lable.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/widgets/gender_selector_row_widget.dart';
import 'package:roboo/core/widgets/password_textfield.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/robot_message_bubble.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/auth/data/models/register_request_model.dart';
import 'package:roboo/features/auth/presentation/view-model/register_cubit/register_cubit.dart';
import 'package:roboo/features/auth/presentation/views/register/view/widgets/source_selector_widget.dart';
import '../../../../../../core/widgets/custome_text_field.dart';
import 'register_verification_screen.dart';
import '../../widgets/auth_footer_widget.dart';
import '../../widgets/auth_header_widget.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _selectedGender = "";
  final List<String> _selectedSources = [];

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _dateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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

  void _submitRegister(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedGender.isEmpty) {
      messages(context, "please_select_gender".tr(context), Colors.red);
      return;
    }

    if (_selectedSources.isEmpty) {
      messages(context, "please_select_source".tr(context), Colors.red);
      return;
    }

    final language = Localizations.localeOf(context).languageCode;
    final fcmToken = CacheHelper.getData(key: 'fcm_token')?.toString() ?? '';
    final name = _nameController.text.trim();
    final nameAr = _nameArController.text.trim();

    context.read<RegisterCubit>().register(
      RegisterRequestModel(
        name: name,
        nameAr: nameAr,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        birthdate: _dateController.text.trim(),
        gender: _selectedGender,
        language: language,
        heardAbout: List<String>.from(_selectedSources),
        fcmToken: fcmToken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(getit.get()),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterError) {
            messages(context, state.errorMsg.tr(context), Colors.red);
          } else if (state is RegisterSuccess) {
            Navigator.pushReplacementNamed(
              context,
              RegisterVerificationScreen.routeName,
              arguments: _emailController.text.trim(),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;

          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: [
                  const Positioned.fill(child: DotBackground()),
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const AuthHeader(),
                          const SizedBox(height: 20),
                          Hero(
                            tag: 'message_bubble',
                            child: RobotMessageBubble(
                              message: "register_welcome".tr(context),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildLabel("what_is_your_name".tr(context)),
                                CustomTextField(
                                  hintText: "name_hint".tr(context),
                                  keyboardType: TextInputType.name,
                                  controller: _nameController,
                                  validator: (value) => Validator.validate(
                                    value,
                                    ValidationState.normal,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                buildLabel(
                                  "what_is_your_arabic_name".tr(context),
                                ),
                                CustomTextField(
                                  hintText: "name_ar_hint".tr(context),
                                  keyboardType: TextInputType.name,
                                  controller: _nameArController,
                                  validator: (value) => Validator.validate(
                                    value,
                                    ValidationState.normal,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                buildLabel("birth_date".tr(context)),
                                GestureDetector(
                                  onTap: isLoading ? null : _pickDate,
                                  child: AbsorbPointer(
                                    child: CustomTextField(
                                      controller: _dateController,
                                      hintText: "birth_date".tr(context),
                                      suffixIcon: Icons.calendar_today_outlined,
                                      validator: (value) => Validator.validate(
                                        value,
                                        ValidationState.normal,
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                buildLabel("gender_question".tr(context)),
                                GenderSelector(
                                  selectedGender: _selectedGender,
                                  onSelect: (val) {
                                    if (isLoading) return;
                                    setState(() => _selectedGender = val);
                                  },
                                ),
                                const SizedBox(height: 20),
                                buildLabel("where_know_roboo".tr(context)),
                                RegisterSourceSelector(
                                  selectedSources: _selectedSources,
                                  onToggle: isLoading ? (_) {} : _toggleSource,
                                ),
                                const SizedBox(height: 30),
                                buildLabel("enter_credentials".tr(context)),
                                const SizedBox(height: 10),
                                CustomTextField(
                                  hintText: "email_hint".tr(context),
                                  keyboardType: TextInputType.emailAddress,
                                  controller: _emailController,
                                  validator: (value) => Validator.validate(
                                    value,
                                    ValidationState.email,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                PasswordTextField(
                                  hintText: "password_hint".tr(context),
                                  controller: _passwordController,
                                  validator: (value) => Validator.validate(
                                    value,
                                    ValidationState.password,
                                    context,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                PasswordTextField(
                                  hintText: "confirm_password".tr(context),
                                  controller: _confirmPasswordController,
                                  validator: (value) =>
                                      Validator.validateConfirmPassword(
                                        value,
                                        _passwordController.text,
                                        context,
                                      ),
                                ),
                                const SizedBox(height: 30),
                                if (isLoading)
                                  Container(
                                    height: 40,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColors,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.primaryTwoColors,
                                          offset: Offset(0, 3),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  )
                                else
                                  PrimaryButton(
                                    text: "next".tr(context),
                                    enterButton: true,
                                    backgroundColor: AppColors.primaryColors,
                                    mainColor: AppColors.primaryTwoColors,
                                    onTap: () => _submitRegister(context),
                                  ),
                                const SizedBox(height: 20),
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
