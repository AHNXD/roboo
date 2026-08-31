import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/widgets/load_more_listener.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/my-school/data/models/homework_model.dart';
import 'package:roboo/features/app/my-school/presentation/view-model/my_school_cubit/my_school_cubit.dart';
import 'package:roboo/features/app/my-school/presentation/view/homework_details_screen.dart';
import 'package:roboo/features/app/my-school/presentation/view/widgets/enrollment_code_dialog.dart';
import 'package:roboo/features/app/my-school/presentation/view/widgets/homework_list_item_widget.dart';
import 'package:roboo/features/app/my-school/presentation/view/widgets/school_info_card_widget.dart';

class MySchoolScreen extends StatefulWidget {
  static const String routeName = '/my-school';

  const MySchoolScreen({super.key});

  @override
  State<MySchoolScreen> createState() => _MySchoolScreenState();
}

class _MySchoolScreenState extends State<MySchoolScreen> {
  /// The code dialog opens itself once per visit; the button reopens it after
  /// a dismissal so the student is never stuck.
  bool _hasPromptedForCode = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MySchoolCubit(getit.get(), getit.get())..loadSchool(),
      child: Scaffold(
        appBar: CustomAppbar(title: "my_school_title".tr(context)),
        body: SafeArea(
          child: BlocConsumer<MySchoolCubit, MySchoolState>(
            listener: (context, state) {
              if (state is MySchoolNotEnrolled && !_hasPromptedForCode) {
                _hasPromptedForCode = true;
                _openCodeDialog(context);
              } else if (state is MySchoolRedeemSuccess) {
                messages(
                  context,
                  "school_joined_successfully".tr(context),
                  AppColors.green,
                );
              } else if (state is MySchoolRedeemError) {
                messages(context, state.errorMsg.tr(context), AppColors.red);
              }
            },
            builder: (context, state) {
              return switch (state) {
                MySchoolInitial() ||
                MySchoolLoading() ||
                MySchoolRedeeming() ||
                MySchoolRedeemSuccess() => StatusDisplayWidget(
                  message: "wait".tr(context),
                  withAnimation: true,
                ),
                MySchoolError(:final errorMsg) => StatusDisplayWidget(
                  message: errorMsg.tr(context),
                ),
                MySchoolNotEnrolled() || MySchoolRedeemError() =>
                  _NotEnrolledView(onEnterCode: () => _openCodeDialog(context)),
                MySchoolLoaded() => _SchoolContent(state: state),
              };
            },
          ),
        ),
      ),
    );
  }

  void _openCodeDialog(BuildContext context) {
    EnrollmentCodeDialog.show(
      context,
      context.read<MySchoolCubit>().redeemCode,
    );
  }
}

class _NotEnrolledView extends StatelessWidget {
  final VoidCallback onEnterCode;

  const _NotEnrolledView({required this.onEnterCode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StatusDisplayWidget(
            message: "not_enrolled_message".tr(context),
            imagePath: AssetsData.flyingRoboo,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: PrimaryButton(
            text: "enter_school_code".tr(context),
            backgroundColor: AppColors.primaryColors,
            mainColor: AppColors.primaryTwoColors,
            enterButton: true,
            onTap: onEnterCode,
          ),
        ),
      ],
    );
  }
}

class _SchoolContent extends StatelessWidget {
  final MySchoolLoaded state;

  const _SchoolContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<MySchoolCubit>().loadSchool,
      child: LoadMoreListener(
        canLoadMore: state.hasMore && !state.isLoadingMore,
        onLoadMore: context.read<MySchoolCubit>().loadMoreHomework,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SchoolInfoCard(enrollment: state.enrollment),
            const SizedBox(height: 16),

            Text(
              "homework_title".tr(context),
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            if (state.homework.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  "no_homework_available".tr(context),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(color: Colors.grey),
                ),
              )
            else
              ...state.homework.map(
                (homework) => HomeworkListItem(
                  homework: homework,
                  onTap: () => _openHomework(context, homework),
                ),
              ),

            if (state.isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColors,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openHomework(BuildContext context, HomeworkModel homework) {
    final homeworkId = homework.id;

    Navigator.pushNamed(
      context,
      HomeworkDetailsScreen.routeName,
      arguments: homeworkId == null
          ? null
          : HomeworkDetailsArgs(homeworkId: homeworkId),
    ).then((_) {
      if (!context.mounted) return;
      // Coming back from a submission, the status chip must be up to date.
      context.read<MySchoolCubit>().loadSchool();
    });
  }
}
