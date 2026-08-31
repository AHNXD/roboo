import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_video_player.dart';

/// Full-screen playback for a single stream — the course intro video, and any
/// other video that is not part of a lesson curriculum. Mirrors
/// `FullScreenImageViewer.show`.
class FullScreenVideoPlayer extends StatelessWidget {
  final String url;
  final String? title;
  final String? thumbnailUrl;

  const FullScreenVideoPlayer({
    super.key,
    required this.url,
    this.title,
    this.thumbnailUrl,
  });

  /// No-op when there is no url, so callers can wire a tap handler without
  /// guarding first.
  static void show(
    BuildContext context, {
    required String? url,
    String? title,
    String? thumbnailUrl,
  }) {
    if (url == null || url.trim().isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullScreenVideoPlayer(
          url: url,
          title: title,
          thumbnailUrl: thumbnailUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: title == null
            ? null
            : Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      body: Center(
        child: AppVideoPlayer(url: url, thumbnailUrl: thumbnailUrl),
      ),
    );
  }
}
