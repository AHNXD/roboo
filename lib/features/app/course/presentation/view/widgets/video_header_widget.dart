import 'package:flutter/material.dart';

class VideoPlayerHeader extends StatelessWidget {
  const VideoPlayerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
      ),
    );
  }
}
