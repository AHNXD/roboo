import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/features/auth/presentation/view-model/logout_cubit/logout_cubit.dart';
import 'package:roboo/features/shared/on-boarding/presentation/view/on_boarding_screen.dart';
import 'package:roboo/core/widgets/custom_3d_btn.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/go_to_button.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/features/app/profile/data/models/cached_profile_user.dart';
import 'package:roboo/features/app/orders/presentation/view/order_history_screen.dart';
import 'package:roboo/features/app/profile/presentation/view/change_password_screen.dart';
import 'package:roboo/features/app/profile/presentation/view/widgets/profile_header_widget.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'edit_profile_screen.dart';
import '../../../my-courses/presentation/view/my_courses_screen.dart';

class ProfileMenuScreen extends StatefulWidget {
  static const String routeName = '/profile-menu';

  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  CachedProfileUser _user = CachedProfileUser.fromCache();

  void _refreshUser() {
    setState(() => _user = CachedProfileUser.fromCache());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LogoutCubit(getit.get()),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: (context, state) {
          if (state is AccountDeleted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              OnboardingScreen.routeName,
              (route) => false,
            );
          } else if (state is LogoutError) {
            messages(context, state.errorMsg.tr(context), AppColors.red);
          }
        },
        builder: (context, state) => _buildScaffold(context, state),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, LogoutState state) {
    final isDeleting = state is LogoutLoading;

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
            text: isDeleting
                ? "wait".tr(context)
                : "delete_account".tr(context),
            iconData: Icons.delete,
            onTap: isDeleting ? () {} : () => _confirmDelete(context),
          ),
        ),
      ),
      appBar: CustomAppbar(title: "profile_title".tr(context)),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            ProfileHeader(
              name: _user.name,
              points: _user.points,
              imagePath: _user.image,
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
                    onTap: () async {
                      await Navigator.pushNamed(
                        context,
                        EditProfileScreen.routeName,
                      );
                      if (mounted) {
                        _refreshUser();
                      }
                    },
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
                    title: "order_history_title".tr(context),
                    image: AssetsData.cart,
                    onTap: () => Navigator.pushNamed(
                      context,
                      OrderHistoryScreen.routeName,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoToButton(
                    title: "change_password".tr(context),
                    image: AssetsData.changePassword,
                    onTap: () => Navigator.pushNamed(
                      context,
                      ChangePasswordScreen.routeName,
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

  /// Deletion cannot be undone, so it asks twice over: a dialog that names the
  /// consequence, with the destructive action as the non-default choice.
  void _confirmDelete(BuildContext context) {
    final cubit = context.read<LogoutCubit>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "delete_account_title".tr(dialogContext),
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "delete_account_warning".tr(dialogContext),
          style: GoogleFonts.cairo(color: Colors.grey[800], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "back".tr(dialogContext),
              style: GoogleFonts.cairo(
                color: AppColors.primaryColors,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.deleteAccount();
            },
            child: Text(
              "delete_account_confirm".tr(dialogContext),
              style: GoogleFonts.cairo(
                color: AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
