import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_list_item_widget.dart';
import 'package:roboo/features/app/home/presentation/view/widgets/course_progress_bar.dart';

class CourseVideosTab extends StatelessWidget {
  const CourseVideosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SizedBox(
          width: double.infinity,
          child: CourseProgressBar(progress: 60, inCourse: true),
        ),
        const SizedBox(height: 20),

        // Pass integers now:
        VideoChapterItem(
          title: "vid_title_1".tr(context),
          durationMinutes: 20,
          status: VideoStatus.completed,
        ),
        VideoChapterItem(
          title: "vid_title_2".tr(context),
          durationMinutes: 10,
          status: VideoStatus.downloaded,
        ),
        VideoChapterItem(
          title: "vid_title_3".tr(context),
          durationMinutes: 35,
          status: VideoStatus.active,
        ),
        VideoChapterItem(
          title: "vid_title_quiz".tr(context),
          durationMinutes: 35,
          status: VideoStatus.locked,
          isQuiz: true,
        ),
      ],
    );
  }
}
