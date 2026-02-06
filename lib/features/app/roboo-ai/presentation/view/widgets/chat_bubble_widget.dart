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
    // Align based on sender
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser ? AppColors.primaryColors : const Color(0xFFE8ECEC);
    final textColor = isUser ? Colors.white : Colors.black87;

    if (!isUser) {
      // AI Message with Icon
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(AssetsData.flyingRoboo, width: 40),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.6),
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
        margin: const EdgeInsets.only(bottom: 16, left: 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(4),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
      ),
    );
  }
}
