import 'package:flutter/material.dart';
import 'package:roboo/core/utils/assets_data.dart';
import 'package:roboo/core/utils/colors.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';
import 'package:roboo/core/widgets/dot_background.dart';

import '../../../../../core/widgets/custom_send_button.dart';

class RobooAiScreen extends StatefulWidget {
  static const String routeName = "/roboo-ai";
  const RobooAiScreen({super.key});

  @override
  State<RobooAiScreen> createState() => _RobooAiScreenState();
}

class _RobooAiScreenState extends State<RobooAiScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Chat History
  final List<Message> _messages = [];

  // Suggestion Chips Data
  final List<String> _suggestions = [
    "كيف أتعلم البرمجة خطوة بخطوة؟",
    "كيف أبدأ بتعلم الروبوتيك؟",
  ];

  // Function to send message
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      // 1. Add User Message
      _messages.add(Message(text: text, isUser: true));

      // 2. Simulate AI Response (Hardcoded for the specific screenshot example)
      if (text.contains("الروبوتيك")) {
        _messages.add(
          Message(
            text: """ابدأ بتعلّم الروبوتيك خطوة بخطوة! 🚀
أولاً، لازم تعرف إن الروبوت هو آلة نقدر نبرمجها لتقوم بمهام محددة — مثل التحرك، التقاط الأشياء، أو حتى حل الألغاز 😄
🔹 الخطوة 1: تعرّف على أجزاء الروبوت
الروبوت يتكوّن عادة من:
• محركات (Motors) تساعده على الحركة 🏃
• مستشعر (Sensors) تجعله "يشعر" بما حوله 👀
• لوحة تحكم (Controller) مثل دماغه 🧠
• هيكل (Frame) يجمع كل القطع معاً ⚙️

🔹 الخطوة 2: تعلّم كيف تبرمجه
ابدأ بلغة بسيطة مثل Scratch أو Blockly، حيث تبرمج عن طريق السحب والإفلات — بدون كتابة أكواد صعبة!""",
            isUser: false,
          ),
        );
      }
    });

    _controller.clear();

    // Scroll to bottom after frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppbar(title: "المساعد روبو"),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: DotBackground()),

            Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : _buildChatList(),
                ),

                _buildFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Robot Image
            Image.asset(AssetsData.flyingRoboo),
            const SizedBox(height: 30),
            // Title
            const Text(
              "أهلاً بك في المساعد الذكي روبو!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            const Text(
              "نستطيع مساعدتك في حال لديك أي سؤال عن البرمجة، الروبوتيك، الذكاء الاصطناعي، أو عن التطبيق.\nلا تتردد في طلب مساعدتنا",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _ChatBubble(message: msg);
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20, left: 16, right: 16),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: true, // Arabic RTL flow
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _sendMessage(_suggestions[index]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.primaryColors.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _suggestions[index],
                      style: TextStyle(
                        color: AppColors.primaryColors.withValues(alpha: 0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: CustomTextField(hintText: "اسأل")),
              const SizedBox(width: 10),
              CustomSendButton(
                isWhite: false,
                onTap: () => _sendMessage(_controller.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Helper Classes ---

class Message {
  final String text;
  final bool isUser;
  Message({required this.text, required this.isUser});
}

class _ChatBubble extends StatelessWidget {
  final Message message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bgColor = isUser ? AppColors.primaryColors : const Color(0xFFE8ECEC);
    final textColor = isUser ? Colors.white : Colors.black87;

    if (!isUser) {
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
