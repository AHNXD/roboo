import 'package:flutter/material.dart';
import 'package:roboo/features/app/my-school/data/models/homework_submission_model.dart';
import 'package:roboo/core/widgets/full_screen_video_player.dart';
import 'package:roboo/core/widgets/full_screen_image_viewer.dart';
import 'package:roboo/core/widgets/custom_image_widget.dart';
import 'package:roboo/core/utils/external_links.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/my-school/data/models/homework_model.dart';
import 'package:roboo/features/app/my-school/presentation/view-model/homework_details_cubit/homework_details_cubit.dart';
import 'package:roboo/features/app/quizes/presentation/view/widgets/quize_option_item_widget.dart';

class HomeworkDetailsArgs {
  final int homeworkId;

  const HomeworkDetailsArgs({required this.homeworkId});

  static int? homeworkIdFrom(Object? args) {
    if (args is HomeworkDetailsArgs) return args.homeworkId;
    if (args is int) return args;
    if (args is Map && args['homeworkId'] is int) {
      return args['homeworkId'] as int;
    }
    return null;
  }
}

class HomeworkDetailsScreen extends StatefulWidget {
  static const String routeName = '/homework-details';

  final int? homeworkId;

  const HomeworkDetailsScreen({super.key, required this.homeworkId});

  factory HomeworkDetailsScreen.fromRouteArgs(Object? args) {
    return HomeworkDetailsScreen(
      homeworkId: HomeworkDetailsArgs.homeworkIdFrom(args),
    );
  }

  @override
  State<HomeworkDetailsScreen> createState() => _HomeworkDetailsScreenState();
}

class _HomeworkDetailsScreenState extends State<HomeworkDetailsScreen> {
  final TextEditingController _answerController = TextEditingController();

  /// The image or video chosen for the file-backed types, before it is sent.
  XFile? _pickedFile;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HomeworkDetailsCubit(getit.get())
            ..getHomeworkDetails(widget.homeworkId),
      child: Scaffold(
        appBar: CustomAppbar(title: "homework_title".tr(context)),
        body: SafeArea(
          child: BlocConsumer<HomeworkDetailsCubit, HomeworkDetailsState>(
            listener: (context, state) {
              if (state is HomeworkSubmitSuccess) {
                messages(
                  context,
                  "homework_submitted_successfully".tr(context),
                  AppColors.green,
                );
              } else if (state is HomeworkSubmitError) {
                messages(context, state.errorMsg.tr(context), AppColors.red);
              }
            },
            builder: (context, state) {
              return switch (state) {
                HomeworkDetailsInitial() ||
                HomeworkDetailsLoading() ||
                HomeworkSubmitSuccess() ||
                HomeworkSubmitError() => StatusDisplayWidget(
                  message: "wait".tr(context),
                  withAnimation: true,
                ),
                HomeworkDetailsError(:final errorMsg) => StatusDisplayWidget(
                  message: errorMsg.tr(context),
                ),
                HomeworkDetailsLoaded() => _buildContent(context, state),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeworkDetailsLoaded state) {
    final homework = state.homework;
    final languageCode = Localizations.localeOf(context).languageCode;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          homework.titleFor(languageCode),
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        if (homework.descriptionFor(languageCode).isNotEmpty)
          Text(
            homework.descriptionFor(languageCode),
            style: GoogleFonts.cairo(color: Colors.grey[700], fontSize: 13),
          ),
        const SizedBox(height: 12),
        _buildMetaRow(context, homework, languageCode),
        const SizedBox(height: 16),

        if (homework.mySubmission != null)
          _SubmissionBanner(homework: homework, languageCode: languageCode)
        else if (homework.type == HomeworkType.mcq)
          ..._buildQuestions(context, state)
        else if (homework.type == HomeworkType.other)
          Text(
            "homework_type_unsupported".tr(context),
            style: GoogleFonts.cairo(color: Colors.grey),
          )
        else ...[
          // text, image, video and the two combinations — a type may need the
          // written answer, the file, or both.
          if (homework.type.needsText) _buildTextAnswer(context, state),
          if (homework.type.needsFile) _buildFilePicker(context, state),
        ],

        if (homework.mySubmission == null &&
            homework.type != HomeworkType.other) ...[
          const SizedBox(height: 24),
          PrimaryButton(
            text: state.isSubmitting
                ? "wait".tr(context)
                : "submit_homework".tr(context),
            backgroundColor: AppColors.primaryColors,
            mainColor: AppColors.primaryTwoColors,
            enterButton: true,
            onTap: () => _onSubmit(context, state),
          ),
        ],
      ],
    );
  }

  Widget _buildMetaRow(
    BuildContext context,
    HomeworkModel homework,
    String languageCode,
  ) {
    final teacher = homework.creatorNameFor(languageCode);
    final dueDate = homework.dueDate;

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        if (dueDate.isNotEmpty)
          _metaChip(
            Icons.event_outlined,
            "${"due_on".tr(context)} $dueDate",
            homework.isOverdue ? AppColors.red : Colors.grey,
          ),
        if (homework.maxScore != null)
          _metaChip(
            Icons.grade_outlined,
            "${"max_score".tr(context)} ${homework.maxScore}",
            Colors.grey,
          ),
        if (teacher.isNotEmpty)
          _metaChip(Icons.person_outline, teacher, Colors.grey),
      ],
    );
  }

  Widget _metaChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.cairo(fontSize: 12, color: color)),
      ],
    );
  }

  List<Widget> _buildQuestions(
    BuildContext context,
    HomeworkDetailsLoaded state,
  ) {
    final homeworkCubit = context.read<HomeworkDetailsCubit>();
    final languageCode = Localizations.localeOf(context).languageCode;

    return state.homework.questions.map((question) {
      final questionId = question.id;
      final selectedOptionId = questionId == null
          ? null
          : state.selectedAnswers[questionId];

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.questionFor(languageCode),
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ...question.options.map(
              (option) => QuizOptionItem(
                text: option.labelFor(languageCode),
                isSelected: selectedOptionId == option.id,
                onTap: (questionId == null || option.id == null)
                    ? null
                    : () => homeworkCubit.selectOption(
                        questionId: questionId,
                        optionId: option.id!,
                      ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildTextAnswer(BuildContext context, HomeworkDetailsLoaded state) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColors.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _answerController,
        enabled: !state.isSubmitting,
        maxLines: 10,
        decoration: InputDecoration(
          hintText: "homework_answer_hint".tr(context),
          hintStyle: const TextStyle(color: Colors.black26),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Future<void> _pickFile(HomeworkModel homework) async {
    final picker = ImagePicker();

    // Same picker either way; a video homework asks for a video.
    final picked = homework.type.needsVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 85,
            requestFullMetadata: false,
          );

    if (picked == null || !mounted) return;
    setState(() => _pickedFile = picked);
  }

  void _onSubmit(BuildContext context, HomeworkDetailsLoaded state) {
    if (state.isSubmitting) return;

    final homework = state.homework;
    final homeworkCubit = context.read<HomeworkDetailsCubit>();

    if (homework.type == HomeworkType.mcq) {
      if (!state.canSubmitMcq) {
        messages(context, "answer_all_questions".tr(context), AppColors.red);
        return;
      }

      homeworkCubit.submitMcq();
      return;
    }

    // The combination types need both halves, so each is reported on its own
    // rather than with one vague "something is missing".
    if (homework.type.needsText && _answerController.text.trim().isEmpty) {
      messages(context, "this_field_is_required".tr(context), AppColors.red);
      return;
    }

    if (homework.type.needsFile && _pickedFile == null) {
      messages(
        context,
        homework.type.needsVideo
            ? "homework_video_required".tr(context)
            : "homework_image_required".tr(context),
        AppColors.red,
      );
      return;
    }

    homeworkCubit.submitAnswer(
      content: homework.type.needsText ? _answerController.text : null,
      filePath: _pickedFile?.path,
    );
  }

  /// The file picker for the image and video types, showing what was chosen.
  Widget _buildFilePicker(BuildContext context, HomeworkDetailsLoaded state) {
    final homework = state.homework;
    final picked = _pickedFile;
    final isVideo = homework.type.needsVideo;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: GestureDetector(
        onTap: state.isSubmitting ? null : () => _pickFile(homework),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: picked == null
                  ? Colors.grey.withValues(alpha: 0.4)
                  : AppColors.primaryColors,
            ),
          ),
          child: Row(
            children: [
              Icon(
                picked != null
                    ? Icons.check_circle
                    : (isVideo
                          ? Icons.videocam_outlined
                          : Icons.image_outlined),
                color: picked != null
                    ? AppColors.green
                    : AppColors.primaryColors,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  picked?.name ??
                      (isVideo
                          ? "homework_pick_video".tr(context)
                          : "homework_pick_image".tr(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: picked == null ? Colors.grey[700] : Colors.black87,
                    fontWeight: picked == null
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
              ),
              if (picked != null)
                Text(
                  "change".tr(context),
                  style: GoogleFonts.cairo(
                    color: AppColors.primaryColors,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmissionBanner extends StatelessWidget {
  final HomeworkModel homework;
  final String languageCode;

  const _SubmissionBanner({required this.homework, required this.languageCode});

  @override
  Widget build(BuildContext context) {
    final submission = homework.mySubmission!;
    final hasScore = submission.hasVisibleScore;
    final color = hasScore ? AppColors.shadowGreen : AppColors.primaryTwoColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasScore
                    ? "${"homework_score".tr(context)} ${submission.score}/${homework.maxScore ?? '-'}"
                    : "homework_awaiting_mark".tr(context),
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (submission.feedback?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  "${"teacher_feedback".tr(context)}: ${submission.feedback}",
                  style: GoogleFonts.cairo(fontSize: 13, color: Colors.black87),
                ),
              ],
            ],
          ),
        ),

        if (submission.content?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text(
            "your_answer".tr(context),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            submission.content!,
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[700]),
          ),
        ],

        // The image or video the student uploaded, so they can see what the
        // teacher is marking.
        if (submission.attachment != null &&
            submission.attachment!.url.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            "homework_your_file".tr(context),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _SubmittedAttachment(attachment: submission.attachment!),
        ],

        if (homework.questions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            "your_answer".tr(context),
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...homework.questions.map((question) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final result = submission.resultFor(question.id);

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (result != null) ...[
                            Icon(
                              result.isCorrect
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 18,
                              color: result.isCorrect
                                  ? Colors.green
                                  : AppColors.red,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              question.questionFor(languageCode),
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Once the teacher releases the mark the submission carries
                  // `question_results`, so right and wrong come from the server.
                  // Before that only the student's own answer is shown back.
                  ...question.options.map((option) {
                    final result = submission.resultFor(question.id);
                    final isChosen =
                        option.id != null &&
                        (result?.selectedOptionId == option.id ||
                            submission.answers.contains(option.id));

                    Color? color;
                    IconData? icon;
                    if (result != null && option.id != null) {
                      if (option.id == result.correctOptionId) {
                        color = Colors.green;
                        icon = Icons.check_circle;
                      } else if (isChosen) {
                        color = AppColors.red;
                        icon = Icons.cancel;
                      }
                    }

                    return QuizOptionItem(
                      text: option.labelFor(languageCode),
                      isSelected: isChosen,
                      borderColor: color,
                      iconColor: color,
                      icon: icon,
                      onTap: null,
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}

/// The uploaded file on a submission: an image is shown, a video opens in the
/// player, and anything else — the backend does not check the mime type, so a
/// wrong file can land here — opens in the browser rather than pretending to
/// be something it is not.
class _SubmittedAttachment extends StatelessWidget {
  final HomeworkAttachmentModel attachment;

  const _SubmittedAttachment({required this.attachment});

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage) {
      return GestureDetector(
        onTap: () =>
            FullScreenImageViewer.show(context, imageUrls: [attachment.url]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomImageWidget(
            imageUrl: attachment.url,
            placeholderAsset: AssetsData.logo,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => attachment.isVideo
          ? FullScreenVideoPlayer.show(context, url: attachment.url)
          : ExternalLinks.openUrl(context, attachment.url),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(
              attachment.isVideo
                  ? Icons.play_circle_fill
                  : Icons.insert_drive_file_outlined,
              color: AppColors.primaryColors,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                attachment.name ?? attachment.url.split('/').last,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
