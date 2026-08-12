import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_genui_kit/flutter_genui_kit.dart';

import '../providers/genkit_llm_provider.dart';
import '../widgets/zen_background.dart';

class _DummyGenUiAdapter implements GenUiLlmAdapter {
  @override
  Future<GenUiCompletion> generate({
    required String prompt,
    GenUiDocument? currentDocument,
    Map<String, Object?> context = const {},
  }) async {
    return const GenUiCompletion(rawPayload: '{}');
  }
}

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

  Widget _buildResponse(BuildContext context, String text) {
    // Try parsing the entire text first
    var parsed = const GenUiSchemaParser().parse(text);
    if (parsed is GenUiSuccess<GenUiParsedDocument>) {
      return GenUiBuilder(
        controller: GenUiController(
          adapter: _DummyGenUiAdapter(),
          initialDocument: parsed.value.document,
        ),
      );
    }

    // Extract json from markdown block if any
    final jsonRegex = RegExp(r'```(?:json)?\n(.*?)```', dotAll: true);
    final match = jsonRegex.firstMatch(text);
    if (match != null) {
      final jsonStr = match.group(1);
      if (jsonStr != null && jsonStr.trim().isNotEmpty) {
        parsed = const GenUiSchemaParser().parse(jsonStr.trim());
        if (parsed is GenUiSuccess<GenUiParsedDocument>) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: text.replaceAll(match.group(0)!, '').trim(),
                selectable: false,
              ),
              const SizedBox(height: 16),
              GenUiBuilder(
                controller: GenUiController(
                  adapter: _DummyGenUiAdapter(),
                  initialDocument: parsed.value.document,
                ),
              ),
            ],
          );
        }
      }
    }

    return MarkdownBody(data: text, selectable: false);
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
            responseBuilder: _buildResponse,
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
