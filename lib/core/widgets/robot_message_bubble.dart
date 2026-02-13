import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';

class RobotMessageBubble extends StatelessWidget {
  final String message;
  final String robotImage;

  const RobotMessageBubble({
    super.key,
    required this.message,
    this.robotImage = AssetsData.flyingRoboo,
  });

  @override
  Widget build(BuildContext context) {
    const double imageSize = 150.0;
    const double halfImageSize = imageSize / 2;

    // 1. Get the current text direction (LTR or RTL)
    final TextDirection currentDirection = Directionality.of(context);
    final bool isRtl = currentDirection == TextDirection.rtl;

    // Tail width for the inner padding calculation
    const double tailWidth = 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: imageSize),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentDirectional.bottomStart,
          children: [
            // 2. The Message Bubble
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start:
                    halfImageSize +
                    20, // Slightly reduced to let the tail point closer to the robot
                bottom: halfImageSize + 20,
              ),
              child: Material(
                type: MaterialType.transparency,
                // 3. Apply the ClipPath for the sharp tail
                child: ClipPath(
                  clipper: RobotBubbleClipper(isRtl: isRtl),
                  child: Container(
                    width: double.infinity,
                    // 4. Add the tailWidth to the 'start' padding so text doesn't overlap the tail
                    padding: const EdgeInsetsDirectional.only(
                      start: 16 + tailWidth,
                      end: 16,
                      top: 16,
                      bottom: 16,
                    ),
                    color: const Color(
                      0xFFE8ECEC,
                    ), // Moved color here from BoxDecoration
                    child: Text(
                      message,
                      style: TextStyle(
                        color: AppColors.textButtonColors,
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5. The Robot Image
            Positioned.directional(
              textDirection: currentDirection,
              start: 0,
              bottom: 0,
              child: Transform.flip(
                flipX: !isRtl,
                child: Image.asset(
                  robotImage,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM CLIPPER: Draws the sharp tail pointing to the bottom robot
// ---------------------------------------------------------
class RobotBubbleClipper extends CustomClipper<Path> {
  final bool isRtl;

  RobotBubbleClipper({required this.isRtl});

  @override
  Path getClip(Size size) {
    Path path = Path();
    const double r = 20.0; // Corner radius
    const double tailWidth = 16.0; // How far the tail sticks out horizontally
    const double tailHeight = 24.0; // How far up the side the tail connects

    // 1. Draw the standard LTR shape (Tail at the Bottom-Left)
    // Start at Top-Left (after the corner curve)
    path.moveTo(tailWidth + r, 0);

    // Top Edge & Top-Right Corner
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);

    // Right Edge & Bottom-Right Corner
    path.lineTo(size.width, size.height - r);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - r,
      size.height,
    );

    // Bottom Edge (to the base of the tail)
    path.lineTo(tailWidth, size.height);

    // The Sharp Tail (Bottom-Left Tip)
    path.lineTo(0, size.height); // Points straight to the bottom corner
    path.lineTo(tailWidth, size.height - tailHeight); // Slants back up

    // Left Edge & Top-Left Corner
    path.lineTo(tailWidth, r);
    path.quadraticBezierTo(tailWidth, 0, tailWidth + r, 0);

    path.close();

    // 2. MAGIC TRICK: If the app is in RTL (Arabic), flip the whole shape horizontally!
    if (isRtl) {
      final Matrix4 matrix = Matrix4.identity()
        ..translate(size.width, 0.0)
        ..scale(-1.0, 1.0); // Mirrors the shape
      return path.transform(matrix.storage);
    }

    return path;
  }

  @override
  bool shouldReclip(covariant RobotBubbleClipper oldClipper) {
    return oldClipper.isRtl != isRtl;
  }
}
