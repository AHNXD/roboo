import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/core/widgets/status_display_widget.dart';
import 'package:roboo/features/app/course/data/models/course_quiz_model.dart';
import 'package:roboo/features/app/course/data/models/lesson_model.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_list_item_widget.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_bar.dart';
import 'package:roboo/features/app/course/presentation/view/video_player_screen.dart';
import 'package:roboo/features/app/quizes/presentation/view/quiz_entry.dart';

class CourseVideosTab extends StatelessWidget {
  final int? courseId;
  final List<LessonModel> lessons;

  /// Quizzes the course carries; listed after the lessons, the way the design
  /// already treated a quiz as the last row of the curriculum.
  final List<CourseQuizModel> quizzes;

  final double progress;

  /// Fired after the player screen closes having marked a lesson watched, so
  /// the course can re-fetch its progress.
  final VoidCallback onProgressChanged;

  /// A locked course still lists its curriculum: free-preview lessons are
  /// playable and badged, everything else shows as locked. Progress and course
  /// quizzes are meaningless until the course is bought.
  final bool isUnlocked;

  /// The course's topic icon, forwarded to the player's header badge.
  final String topicImageUrl;

  /// Forwarded to the player's header badge.
  final Color? topicColor;

  const CourseVideosTab({
    super.key,
    required this.courseId,
    required this.lessons,
    required this.onProgressChanged,
    required this.quizzes,
    required this.progress,
    this.isUnlocked = true,
    this.topicImageUrl = '',
    this.topicColor,
  });

  /// Only a preview whose video is actually uploaded can be played. Course 2's
  /// previews carry no url, and offering one that cannot play is worse than
  /// offering none.
  bool _isPlayablePreview(LessonModel lesson) =>
      !lesson.isLocked && lesson.hasVideo;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty && quizzes.isEmpty) {
      return StatusDisplayWidget(message: "no_lessons_available".tr(context));
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    final showProgress = isUnlocked;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: lessons.length + quizzes.length + (showProgress ? 1 : 0),
      itemBuilder: (context, index) {
        if (showProgress && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              width: double.infinity,
              child: CourseProgressBar(progress: progress, inCourse: true),
            ),
          );
        }

        final itemIndex = showProgress ? index - 1 : index;
        if (itemIndex < lessons.length) {
          final lesson = lessons[itemIndex];
          final isPlayable = isUnlocked
              ? !lesson.isLocked
              : _isPlayablePreview(lesson);

          return VideoChapterItem(
            title: lesson.titleFor(languageCode),
            durationMinutes: lesson.durationMinutes,
            status: isPlayable ? _statusFor(lesson) : VideoStatus.locked,
            isFreePreview: !isUnlocked && isPlayable,
            imageUrl: lesson.videoThumbnail,
            onTap: isPlayable ? () => _openPlayer(context, itemIndex) : null,
          );
        }

        final quiz = quizzes[itemIndex - lessons.length];
        final quizId = quiz.id;

        return VideoChapterItem(
          title: quiz.titleFor(languageCode),
          durationMinutes: quiz.durationMinutes,
          // `solved` comes with the course payload, so a finished quiz is
          // marked before the student opens it.
          status: quiz.solved ? VideoStatus.completed : VideoStatus.open,
          isQuiz: true,
          onTap: () => openQuizIfUnsolved(
            context,
            quizId: quizId,
            isSolved: quiz.solved,
            onClosed: onProgressChanged,
          ),
        );
      },
    );
  }

  Future<void> _openPlayer(BuildContext context, int lessonIndex) async {
    final id = courseId;
    if (id == null) return;

    // A locked course hands the player only its previews, so "next video"
    // cannot walk the student into a lesson they have not paid for.
    final playableLessons = isUnlocked
        ? lessons
        : lessons.where(_isPlayablePreview).toList();
    final startAt = isUnlocked
        ? lessonIndex
        : playableLessons.indexOf(lessons[lessonIndex]);
    if (startAt < 0) return;

    final markedWatched = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          args: VideoPlayerArgs(
            courseId: id,
            lessons: playableLessons,
            initialIndex: startAt,
            canMarkWatched: isUnlocked,
            topicImageUrl: topicImageUrl,
            topicColor: topicColor,
          ),
        ),
      ),
    );

    if (markedWatched == true) onProgressChanged();
  }

  /// `downloaded` and `active` describe local download state, which the app
  /// does not track, so lessons only map onto the three server-backed states.
  VideoStatus _statusFor(LessonModel lesson) {
    if (lesson.isLocked) return VideoStatus.locked;
    if (lesson.isWatched) return VideoStatus.completed;
    return VideoStatus.open;
  }
}
