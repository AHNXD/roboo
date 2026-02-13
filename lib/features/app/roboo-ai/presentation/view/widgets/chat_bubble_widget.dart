import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/features/app/roboo-ai/data/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    // Get the app's current text direction (LTR or RTL) to format the text properly inside the bubbles
    final appDirection = Directionality.of(context);

    // 1. Use absolute Alignment (Not Directional) so they NEVER swap sides
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser ? AppColors.primaryColors : const Color(0xFFE8ECEC);
    final textColor = isUser ? Colors.white : Colors.black87;

    const double tailWidth = 12.0;

    if (!isUser) {
      // AI Message with Icon
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Force the Row itself to layout LTR so the Robot Avatar is ALWAYS on the Left
          textDirection: TextDirection.ltr,
          children: [
            Image.asset(AssetsData.flyingRoboo, width: 40),
            const SizedBox(width: 8),
            Expanded(
              child: ClipPath(
                clipper: ChatBubbleClipper(isSender: false), // Left Tail
                child: Container(
                  // Absolute padding (Left tail always gets the extra padding)
                  padding: const EdgeInsets.only(
                    left: 16 + tailWidth,
                    right: 16,
                    top: 14,
                    bottom: 14,
                  ),
                  color: bgColor,
                  // Restore the correct language direction for the text inside
                  child: Directionality(
                    textDirection: appDirection,
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // User Message
    return Align(
      alignment: align,
      child: Container(
        // Absolute margin (Always push from the left)
        margin: const EdgeInsets.only(bottom: 16, left: 50),
        child: ClipPath(
          clipper: ChatBubbleClipper(isSender: true), // Right Tail
          child: Container(
            // Absolute padding (Right tail always gets the extra padding)
            padding: const EdgeInsets.only(
              left: 20,
              right: 20 + tailWidth,
              top: 14,
              bottom: 14,
            ),
            color: bgColor,
            child: Directionality(
              textDirection: appDirection,
              child: Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM CLIPPER: Fixed Shapes (Never mirrors)
// ---------------------------------------------------------
class ChatBubbleClipper extends CustomClipper<Path> {
  final bool isSender;

  ChatBubbleClipper({required this.isSender});

  @override
  Path getClip(Size size) {
    Path path = Path();
    const double r = 20.0; // Corner radius
    const double tailWidth = 12.0; // How far the tail sticks out
    const double tailHeight =
        20.0; // Where the tail connects back to the bubble

    if (isSender) {
      // User Bubble (Tail strictly on Top Right)
      path.moveTo(r, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - tailWidth, tailHeight);
      path.lineTo(size.width - tailWidth, size.height - r);
      path.quadraticBezierTo(
        size.width - tailWidth,
        size.height,
        size.width - tailWidth - r,
        size.height,
      );
      path.lineTo(r, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - r);
      path.lineTo(0, r);
      path.quadraticBezierTo(0, 0, r, 0);
    } else {
      // AI Bubble (Tail strictly on Top Left)
      path.moveTo(0, 0);
      path.lineTo(size.width - r, 0);
      path.quadraticBezierTo(size.width, 0, size.width, r);
      path.lineTo(size.width, size.height - r);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - r,
        size.height,
      );
      path.lineTo(tailWidth + r, size.height);
      path.quadraticBezierTo(
        tailWidth,
        size.height,
        tailWidth,
        size.height - r,
      );
      path.lineTo(tailWidth, tailHeight);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(covariant ChatBubbleClipper oldClipper) {
    return oldClipper.isSender != isSender;
  }
}
