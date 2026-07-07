import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/enums.dart';
import 'package:roboo/core/utils/cache_helper.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/utils/validation.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/custom_field_lable.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';
import 'package:roboo/core/widgets/gender_selector_row_widget.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/profile/data/models/profile_model.dart';
import 'package:roboo/features/app/profile/presentation/view-model/profile_cubit/profile_cubit.dart';
import 'package:roboo/features/app/profile/presentation/view/widgets/editable_profile_avatar_widget.dart';
import 'package:roboo/features/app/profile/presentation/view/widgets/heard_about_selector_widget.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = '/edit-profile';
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedGender = "female";
  String _profileImage = AssetsData.profile;
  String? _selectedImagePath;
  String? _selectedImageName;
  List<String> _selectedSources = const [];
  bool _didPopulate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _dateController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateForm(ProfileUserModel user, {bool force = false}) {
    if (_didPopulate && !force) return;

    _nameController.text = user.name ?? '';
    _nameArController.text = user.nameAr ?? '';
    _dateController.text = user.birthdate ?? '';
    _emailController.text = user.email ?? '';
    _selectedGender = user.gender?.isNotEmpty == true
        ? user.gender!
        : _selectedGender;
    _profileImage = user.image?.isNotEmpty == true
        ? user.image!
        : AssetsData.profile;
    _selectedSources = List<String>.from(user.heardAbout);
    _didPopulate = true;
  }

  Future<void> _pickImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
      requestFullMetadata: false,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImagePath = pickedImage.path;
      _selectedImageName = pickedImage.name;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final latestBirthdate = DateTime(now.year, now.month, now.day - 1);
    final currentBirthdate =
        DateTime.tryParse(_dateController.text) ?? latestBirthdate;
    final initialDate = currentBirthdate.isAfter(latestBirthdate)
        ? latestBirthdate
        : currentBirthdate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: latestBirthdate,
    );

    if (pickedDate == null) return;

    setState(() {
      _dateController.text = pickedDate.toIso8601String().split('T').first;
    });
  }

  void _toggleSource(String key) {
    setState(() {
      if (_selectedSources.contains(key)) {
        _selectedSources.remove(key);
      } else {
        _selectedSources.add(key);
      }
    });
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<ProfileCubit>().updateProfile(
      name: _nameController.text.trim(),
      nameAr: _nameArController.text.trim(),
      birthdate: _dateController.text.trim(),
      gender: _selectedGender,
      language: Localizations.localeOf(context).languageCode,
      heardAbout: _selectedSources,
      fcmToken: CacheHelper.getData(key: 'fcm_token')?.toString(),
      imagePath: _selectedImagePath,
      imageName: _selectedImageName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(getit.get())..getProfile(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            setState(() => _populateForm(state.profile.user));
          } else if (state is ProfileUpdateSuccess) {
            setState(() {
              _selectedImagePath = null;
              _selectedImageName = null;
              _populateForm(state.profile.user, force: true);
            });
            final message = state.profile.message.isNotEmpty
                ? state.profile.message
                : 'profile.updated';
            messages(context, message.tr(context), Colors.green);
          } else if (state is ProfileError) {
            messages(context, state.errorMsg.tr(context), Colors.red);
          }
        },
        builder: (context, state) {
          final isInitialLoading = state is ProfileLoading && !_didPopulate;
          final isSubmitting = state is ProfileSubmitting;

          return Scaffold(
            appBar: CustomAppbar(title: "profile_title".tr(context)),
            bottomNavigationBar: _didPopulate
                ? _ProfileSubmitBar(
                    isLoading: isSubmitting,
                    onSubmit: () => _submit(context),
                  )
                : null,
            body: SafeArea(
              child: isInitialLoading
                  ? StatusDisplayWidget(
                      message: "wait".tr(context),
                      withAnimation: true,
                    )
                  : !_didPopulate && state is ProfileError
                  ? _ProfileRetry(
                      onRetry: () => context.read<ProfileCubit>().getProfile(),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            ProfileAvatarEdit(
                              imagePath: _selectedImagePath ?? _profileImage,
                              onEdit: _pickImage,
                            ),
                            const SizedBox(height: 20),
                            buildLabel("what_is_your_name".tr(context)),
                            CustomTextField(
                              hintText: "name_hint".tr(context),
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              validator: (value) => Validator.validate(
                                value,
                                ValidationState.normal,
                                context,
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildLabel("what_is_your_arabic_name".tr(context)),
                            CustomTextField(
                              hintText: "name_ar_hint".tr(context),
                              controller: _nameArController,
                              keyboardType: TextInputType.name,
                              validator: (value) => Validator.validate(
                                value,
                                ValidationState.normal,
                                context,
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildLabel("birth_date".tr(context)),
                            GestureDetector(
                              onTap: _pickDate,
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
                            buildLabel("email".tr(context)),
                            CustomTextField(
                              hintText: "email".tr(context),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            buildLabel("gender_question".tr(context)),
                            GenderSelector(
                              selectedGender: _selectedGender,
                              enabled: false,
                              onSelect: (val) =>
                                  setState(() => _selectedGender = val),
                            ),
                            const SizedBox(height: 20),
                            buildLabel("where_know_roboo".tr(context)),
                            HeardAboutSelector(
                              selectedSources: _selectedSources,
                              onToggle: _toggleSource,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileSubmitBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSubmit;

  const _ProfileSubmitBar({required this.isLoading, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: isLoading
            ? const _LoadingButton()
            : PrimaryButton(
                text: "save_changes".tr(context),
                enterButton: true,
                backgroundColor: AppColors.primaryColors,
                mainColor: AppColors.primaryTwoColors,
                onTap: onSubmit,
              ),
      ),
    );
  }
}

class _ProfileRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: PrimaryButton(
          text: "retry".tr(context),
          backgroundColor: AppColors.primaryColors,
          mainColor: AppColors.primaryTwoColors,
          onTap: onRetry,
        ),
      ),
    );
  }
}

class _LoadingButton extends StatelessWidget {
  const _LoadingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
