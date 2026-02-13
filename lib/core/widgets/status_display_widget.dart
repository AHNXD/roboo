import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roboo/core/utils/assets_data.dart';

class StatusDisplayWidget extends StatefulWidget {
  final String message;
  final String? imagePath;
  final bool withAnimation; // 1. Added the optional parameter

  const StatusDisplayWidget({
    super.key,
    required this.message,
    this.imagePath,
    this.withAnimation = false, // Defaults to false
  });

  @override
  State<StatusDisplayWidget> createState() => _StatusDisplayWidgetState();
}

// 2. Add SingleTickerProviderStateMixin for the AnimationController
class _StatusDisplayWidgetState extends State<StatusDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 3. Setup the controller to take 1.5 seconds per direction
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 4. Setup the tween: move from 0 to -15 pixels on the Y axis (Upward)
    _animation = Tween<double>(
      begin: 0,
      end: -15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // If animation is requested initially, start it looping back and forth
    if (widget.withAnimation) {
      _controller.repeat(reverse: true);
    }
  }

  // Handle cases where the parent widget changes the 'withAnimation' flag dynamically
  @override
  void didUpdateWidget(StatusDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.withAnimation && !oldWidget.withAnimation) {
      _controller.repeat(reverse: true);
    } else if (!widget.withAnimation && oldWidget.withAnimation) {
      _controller.stop();
      _controller.animateTo(0); // Smoothly return to original position
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64.0),
              // 5. Wrap the image in AnimatedBuilder to rebuild ONLY the image when animating
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _animation.value), // Apply the Y offset
                    child: child,
                  );
                },
                child: Image.asset(widget.imagePath ?? AssetsData.flyingRoboo),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
