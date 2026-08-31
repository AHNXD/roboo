import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/constats.dart';
import 'package:roboo/core/utils/external_links.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/custom_back_button.dart';
import 'package:roboo/core/widgets/custom_image_widget.dart';
import 'package:roboo/core/widgets/filter_chip_icon.dart';
import 'package:roboo/core/widgets/full_screen_image_viewer.dart';
import 'package:roboo/core/widgets/primary_button.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/course/data/models/course_details_model.dart';
import 'package:roboo/features/app/course/presentation/view-model/course_details_cubit/course_details_cubit.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/activation_dialog_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/attachments_tab_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/course_info_tab_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_tab_widget.dart';
import 'video_player_screen.dart';

class CourseDetailsArgs {
  final int courseId;

  const CourseDetailsArgs({required this.courseId});

  static int? courseIdFrom(Object? args) {
    if (args is CourseDetailsArgs) return args.courseId;
    if (args is int) return args;
    if (args is Map && args['courseId'] is int) {
      return args['courseId'] as int;
    }
    return null;
  }
}

class CourseDetailsScreen extends StatefulWidget {
  static const String routeName = "/course-details";

  final int? courseId;
  final bool isFav;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    this.isFav = false,
  });

  factory CourseDetailsScreen.fromRouteArgs(Object? args) {
    return CourseDetailsScreen(courseId: CourseDetailsArgs.courseIdFrom(args));
  }

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CourseDetailsCubit(getit.get())..getCourseDetails(widget.courseId),
      child: BlocConsumer<CourseDetailsCubit, CourseDetailsState>(
        listener: (context, state) {
          if (state is CourseDetailsCouponApplied) {
            messages(
              context,
              "course_unlocked_successfully".tr(context),
              AppColors.green,
            );
          } else if (state is CourseDetailsActionError) {
            messages(context, state.errorMsg.tr(context), AppColors.red);
          }
        },
        builder: (context, state) {
          return switch (state) {
            // Both transient states are followed immediately by a real one, so
            // they only ever reach the user through the listener above.
            CourseDetailsInitial() ||
            CourseDetailsLoading() ||
            CourseDetailsCouponApplied() ||
            CourseDetailsActionError() => _statusScaffold(
              context,
              StatusDisplayWidget(
                message: "wait".tr(context),
                withAnimation: true,
              ),
            ),
            CourseDetailsError(:final errorMsg) => _statusScaffold(
              context,
              StatusDisplayWidget(message: errorMsg.tr(context)),
            ),
            CourseDetailsLoaded(:final course, :final isUnlocking) =>
              _buildContent(context, course, isUnlocking),
          };
        },
      ),
    );
  }

  Widget _statusScaffold(BuildContext context, Widget child) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16.0,
                ),
                child: CustomBackButton(onTap: () => Navigator.pop(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CourseDetailsModel course,
    bool isUnlocking,
  ) {
    return Scaffold(
      bottomNavigationBar: _buildBottomActionBar(context, course, isUnlocking),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeaderBackground(context, course),
          Expanded(child: _buildBottomSheet(context, course)),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground(
    BuildContext context,
    CourseDetailsModel course,
  ) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => FullScreenImageViewer.show(
                  context,
                  imageUrls: [course.imageUrl],
                ),
                child: CustomImageWidget(
                  imageUrl: course.imageUrl,
                  placeholderAsset: AssetsData.logo,
                ),
              ),
            ),
            _buildSafeAreaBackButton(context, course),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeAreaBackButton(
    BuildContext context,
    CourseDetailsModel course,
  ) {
    final topicIcon = course.topic?.imageUrl ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(onTap: () => Navigator.pop(context), isWhite: false),
          // Same rule as the course cards: the real topic icon, or no badge.
          if (topicIcon.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    course.topic?.displayColor ??
                    Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: FilterChipIcon(source: topicIcon, size: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, CourseDetailsModel course) {
    final courseId = course.id ?? widget.courseId;
    final infoTab = CourseInfoTab(course: course, isFav: widget.isFav);

    // A locked course with lessons still shows its curriculum, so a buyer can
    // see what they get and play whatever previews are available. Attachments
    // stay behind the paywall — the API omits them anyway.
    final showVideosTab = course.isUnlocked || course.lessons.isNotEmpty;
    if (!showVideosTab) return infoTab;

    final videosTab = CourseVideosTab(
      courseId: courseId,
      lessons: course.lessons,
      quizzes: course.quizzes,
      progress: course.watchedProgress,
      isUnlocked: course.isUnlocked,
      topicImageUrl: course.topic?.imageUrl ?? '',
      topicColor: course.topic?.displayColor,
      onProgressChanged: () =>
          context.read<CourseDetailsCubit>().getCourseDetails(courseId),
    );

    final tabs = <(String, Widget)>[
      ("course_info_tab", infoTab),
      ("videos_tab", videosTab),
      if (course.isUnlocked)
        (
          "attachments_tab",
          CourseAttachmentsTab(attachments: course.attachments),
        ),
    ];

    // The tab count depends on data that arrives after the screen is built, so
    // the controller comes from DefaultTabController rather than being created
    // in initState with a fixed length.
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          _buildTabBar(context, tabs.map((tab) => tab.$1).toList()),
          Expanded(
            child: TabBarView(children: tabs.map((tab) => tab.$2).toList()),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, List<String> labelKeys) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: TabBar(
        labelColor: AppColors.primaryColors,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primaryColors,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        tabs: labelKeys.map((key) => Tab(text: key.tr(context))).toList(),
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    CourseDetailsModel course,
    bool isUnlocking,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
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
        child: course.isUnlocked
            ? PrimaryButton(
                text: "go_to_video".tr(context),
                backgroundColor: AppColors.primaryColors,
                mainColor: AppColors.primaryTwoColors,
                onTap: () => _openPlayer(context, course),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: isUnlocking
                          ? "wait".tr(context)
                          : course.isOnline
                          ? "book_now".tr(context)
                          : "book_via_whatsapp".tr(context),
                      enterButton: true,
                      backgroundColor: course.isOnline
                          ? AppColors.primaryColors
                          : AppColors.green,
                      mainColor: course.isOnline
                          ? AppColors.primaryTwoColors
                          : AppColors.shadowGreen,
                      onTap: () => _onBookTap(context, course, isUnlocking),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    course.displayPrice,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Resumes at the first lesson the student has not finished, falling back to
  /// the first one once the course is complete.
  Future<void> _openPlayer(
    BuildContext context,
    CourseDetailsModel course,
  ) async {
    final courseId = course.id ?? widget.courseId;
    if (courseId == null || course.lessons.isEmpty) return;

    final firstUnwatched = course.lessons.indexWhere(
      (lesson) => !lesson.isWatched && !lesson.isLocked,
    );
    final cubit = context.read<CourseDetailsCubit>();

    final markedWatched = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          args: VideoPlayerArgs(
            courseId: courseId,
            lessons: course.lessons,
            initialIndex: firstUnwatched == -1 ? 0 : firstUnwatched,
            topicImageUrl: course.topic?.imageUrl ?? '',
            topicColor: course.topic?.displayColor,
          ),
        ),
      ),
    );

    if (markedWatched == true) cubit.getCourseDetails(courseId);
  }

  void _onBookTap(
    BuildContext context,
    CourseDetailsModel course,
    bool isUnlocking,
  ) {
    if (isUnlocking) return;

    final courseCubit = context.read<CourseDetailsCubit>();
    // Either button is the booking CTA the backend wants recorded as a lead.
    courseCubit.recordReserveClick();

    if (course.isOnline) {
      ActivationDialogs.showCodeInputDialog(
        context,
        courseCubit.applyCoupon,
        places: course.availablePlaces,
      );
      return;
    }

    // Offline courses are booked off-app, over WhatsApp, with the course name
    // prefilled. Without a configured number there is nothing to open, so the
    // click is still recorded as a lead and the user is told to expect contact.
    if (!AppContact.hasWhatsApp) {
      messages(context, "reserve_request_sent".tr(context), AppColors.green);
      return;
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    ExternalLinks.openWhatsApp(
      context,
      phone: AppContact.whatsAppNumber,
      message:
          "${"whatsapp_booking_message".tr(context)} "
          "${course.titleFor(languageCode)}",
    );
  }
}
