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
  final List<String> _suggestionKeys = [
    "suggestion_coding",
    "suggestion_robotics",
  ];

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
            text: "mock_robotics_response".tr(context),
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

                // Footer
                _buildFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 20, left: 16, right: 16),
      color: Colors.transparent,
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
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  hintText: "ask_hint".tr(context),
                  controller: _controller,
                ),
              ),
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
