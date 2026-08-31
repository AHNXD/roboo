import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/utils/functions.dart';
import 'package:roboo/core/utils/services_locater.dart';
import 'package:roboo/core/widgets/app_video_player.dart';
import 'package:roboo/core/widgets/secure_screen.dart';
import 'package:roboo/features/app/course/data/models/lesson_model.dart';
import 'package:roboo/features/app/course/presentation/view-model/lesson_player_cubit/lesson_player_cubit.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/next_video_bottom_bar_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_content_body_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_top_nav_widget.dart';

class VideoPlayerArgs {
  final int courseId;
  final List<LessonModel> lessons;
  final int initialIndex;

  /// False while the course is only being previewed. Progress on a course the
  /// student does not own means nothing, so neither the button nor the
  /// automatic call on completion is offered.
  final bool canMarkWatched;

  /// The course's topic icon, for the badge above the player. Empty when the
  /// topic has no picture — the badge is then not drawn.
  final String topicImageUrl;

  /// The topic's colour for that badge; null keeps the neutral default.
  final Color? topicColor;

  const VideoPlayerArgs({
    required this.courseId,
    required this.lessons,
    this.initialIndex = 0,
    this.canMarkWatched = true,
    this.topicImageUrl = '',
    this.topicColor,
  });
}

/// Plays a course's lessons in order. Pops `true` when at least one lesson was
/// marked watched, so the course details screen knows to re-fetch its progress.
class VideoPlayerScreen extends StatelessWidget {
  final VideoPlayerArgs args;

  const VideoPlayerScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    // Course video is paid content, so capture is blocked for as long as this
    // screen is on top and restored the moment it leaves.
    return SecureScreen(
      child: BlocProvider(
        create: (_) => LessonPlayerCubit(
          courseRepo: getit.get(),
          courseId: args.courseId,
          lessons: args.lessons,
          initialIndex: args.initialIndex,
        ),
        child: _VideoPlayerView(args: args),
      ),
    );
  }
}

class _VideoPlayerView extends StatelessWidget {
  final VideoPlayerArgs args;

  const _VideoPlayerView({required this.args});

  bool get canMarkWatched => args.canMarkWatched;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return BlocConsumer<LessonPlayerCubit, LessonPlayerState>(
      listenWhen: (previous, current) => current.actionErrorMsg != null,
      listener: (context, state) {
        messages(context, state.actionErrorMsg!.tr(context), AppColors.red);
        context.read<LessonPlayerCubit>().clearActionError();
      },
      builder: (context, state) {
        final cubit = context.read<LessonPlayerCubit>();
        final lesson = state.currentLesson;
        final nextLesson = state.nextLesson;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            Navigator.pop(context, state.hasMarkedAnyWatched);
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: nextLesson == null
                ? null
                : NextVideoBottomBar(
                    nextVideoTitle: nextLesson.titleFor(languageCode),
                    onNextTap: cubit.playNext,
                  ),
            body: Column(
              children: [
                // Above the video, not over it: the player owns its whole
                // surface for its own controls, and a back button floating on
                // top of them competes for the same taps.
                SafeArea(
                  bottom: false,
                  child: VideoTopNav(
                    onBack: () =>
                        Navigator.pop(context, state.hasMarkedAnyWatched),
                    topicImageUrl: args.topicImageUrl,
                    topicColor: args.topicColor,
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: _buildPlayerArea(context, cubit, lesson),
                ),

                if (lesson != null)
                  Expanded(
                    child: VideoContentBody(
                      lesson: lesson,
                      isWatched: cubit.isWatched(lesson),
                      isMarkingWatched: state.isMarkingWatched,
                      onMarkWatched: canMarkWatched
                          ? cubit.markCurrentWatched
                          : null,
                      onQuizClosed: cubit.reloadAfterQuiz,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerArea(
    BuildContext context,
    LessonPlayerCubit cubit,
    LessonModel? lesson,
  ) {
    if (lesson == null) {
      return _placeholder(context, "no_lessons_available".tr(context));
    }

    if (!lesson.hasVideo) {
      return _placeholder(context, "video_not_available".tr(context));
    }

    return AppVideoPlayer(
      // Rebuilding on the lesson id keeps one controller per lesson instead of
      // reusing a controller that is mid-playback.
      key: ValueKey(lesson.id ?? lesson.videoUrl),
      url: lesson.videoUrl!,
      thumbnailUrl: lesson.videoThumbnail,
      // The signed url may simply have expired; refetching replaces it and the
      // player re-initialises on the new one.
      onFailed: cubit.refreshExpiredUrls,
      onCompleted: canMarkWatched ? cubit.markCurrentWatched : null,
    );
  }

  Widget _placeholder(BuildContext context, String message) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videocam_off_outlined,
            color: Colors.white54,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
