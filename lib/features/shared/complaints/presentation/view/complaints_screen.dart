import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/features/shared/complaints/presentation/view-model/feedback_cubit/feedback_cubit.dart';
import 'package:roboo/features/shared/complaints/presentation/view/widgets/header_text_widget.dart';
import 'package:roboo/features/shared/complaints/presentation/view/widgets/input_field_widget.dart';
import 'package:roboo/features/shared/complaints/presentation/view/widgets/rating_row_widget.dart';

class ComplaintsScreen extends StatefulWidget {
  static const String routeName = '/complaints';
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final TextEditingController _noteController = TextEditingController();
  int _rating = 4;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitFeedback(BuildContext context) {
    final note = _noteController.text.trim();

    if (note.isEmpty) {
      messages(context, "this_field_is_required".tr(context), Colors.red);
      return;
    }

    context.read<FeedbackCubit>().submitFeedback(rating: _rating, note: note);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedbackCubit(getit.get()),
      child: BlocConsumer<FeedbackCubit, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackError) {
            messages(context, state.errorMsg.tr(context), Colors.red);
          } else if (state is FeedbackSubmitSuccess) {
            messages(
              context,
              "feedback_submitted_successfully".tr(context),
              Colors.green,
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is FeedbackSubmitting;

          return Scaffold(
            appBar: CustomAppbar(title: "complaints_title".tr(context)),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const ComplaintsHeader(),
                    const SizedBox(height: 20),
                    ComplaintsRatingRow(
                      profileImage: AssetsData.profile,
                      rating: _rating,
                      onRatingChanged: isSubmitting
                          ? (_) {}
                          : (rating) => setState(() => _rating = rating),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ComplaintInputField(
                        controller: _noteController,
                        enabled: !isSubmitting,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: PrimaryButton(
                        text: isSubmitting
                            ? "wait".tr(context)
                            : "send".tr(context),
                        backgroundColor: AppColors.primaryColors,
                        mainColor: AppColors.primaryTwoColors,
                        enterButton: !isSubmitting,
                        onTap: isSubmitting
                            ? () {}
                            : () => _submitFeedback(context),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
