import 'package:flutter/material.dart';
import 'package:roboo/core/widgets/custom_appbar.dart';
import 'package:roboo/core/widgets/custom_send_button.dart';
import 'package:roboo/core/widgets/custome_text_field.dart';
import 'package:roboo/core/widgets/dot_background.dart';
import 'package:roboo/core/utils/app_localizations.dart';
import 'package:roboo/features/app/roboo-ai/data/models/message_model.dart';
import 'package:roboo/features/app/roboo-ai/presentation/view/widgets/chat_bubble_widget.dart';
import 'package:roboo/features/app/roboo-ai/presentation/view/widgets/empty_state_widget.dart';
import 'package:roboo/features/app/roboo-ai/presentation/view/widgets/suggestion_chips_list_widget.dart';

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
  final List<ChatMessage> _messages = [];

  // Suggestion Keys (Stored as keys to be translated in the widget)
  final List<String> _suggestionKeys = ["faq_q1", "faq_q2", "faq_q3", "faq_q4"];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      // 1. Add User Message
      _messages.add(ChatMessage(text: text, isUser: true));

      // 2. Simulate AI Response
      // Checking for localized string or key keyword
      // (Simplified logic for demo)
      if (text.contains("الروبوتيك") || text.contains("robotics")) {
        _messages.add(
          ChatMessage(
            // Use localization for the long text response
            text: "faq_a1".tr(context),
            isUser: false,
          ),
        );
      }
    });

    _controller.clear();

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
      bottomNavigationBar: _buildFooter(),
      resizeToAvoidBottomInset: true,
      appBar: CustomAppbar(title: "ai_assistant_title".tr(context)),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: DotBackground()),

            Column(
              children: [
                // Chat Area
                Expanded(
                  child: _messages.isEmpty
                      ? const AiChatEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return ChatBubble(message: _messages[index]);
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            offset: Offset(0, -1),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Suggestions
            SuggestionChipsList(
              suggestions: _suggestionKeys,
              onSelect: _sendMessage,
            ),

            const SizedBox(height: 12),

            // Input Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: "ask_hint".tr(context),
                      controller: _controller,
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomSendButton(
                    width: 45,
                    height: 45,
                    isWhite: false,
                    onTap: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
