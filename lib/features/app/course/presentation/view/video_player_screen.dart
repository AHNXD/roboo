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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Top Video Player Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.40,
            child: const VideoPlayerHeader(),
          ),

          // 2. Back Button & Icon Overlay
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: VideoTopNavOverlay(),
          ),

          // 3. Bottom Sheet Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Scrollable Content
                  Expanded(
                    child: VideoContentBody(
                      title: "vid_title_1".tr(
                        context,
                      ), // "01. Introduction to Java"
                    ),
                  ),

                  // Bottom Action Bar
                  NextVideoBottomBar(
                    nextVideoTitle: "vid_title_3".tr(
                      context,
                    ), // "02. Variables..."
                    onNextTap: () {
                      // Handle navigation
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
