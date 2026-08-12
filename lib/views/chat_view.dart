import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

import '../providers/genkit_llm_provider.dart';
import '../widgets/zen_background.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final GenkitLlmProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = GenkitLlmProvider();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ZenBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Butler AI'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: LlmChatView(
            provider: _provider,
            style: LlmChatViewStyle(
              backgroundColor: Colors.transparent,
              userMessageStyle: UserMessageStyle(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer
                      .withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              llmMessageStyle: LlmMessageStyle(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
