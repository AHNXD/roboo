import 'package:flutter/material.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/next_video_bottom_bar_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_content_body_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_header_widget.dart';
import 'package:roboo/features/app/course/presentation/view/widgets/video_top_nav_widget.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NextVideoBottomBar(
        nextVideoTitle: "vid_title_3".tr(context),
        onNextTap: () {},
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(child: const VideoPlayerHeader()),

                  VideoTopNavOverlay(),
                ],
              ),
            ),
          ),

          // 3. Bottom Sheet Content
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            width: double.infinity,
            color: Colors.white,

            child: Column(
              children: [VideoContentBody(title: "vid_title_1".tr(context))],
            ),
          ),
        ],
      ),
    );
  }
}
