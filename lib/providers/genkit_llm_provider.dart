import 'package:flutter/foundation.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

import '../db.dart';
import '../services/ai_service.dart';

class GenkitLlmProvider extends LlmProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final AiService _aiService;
  final List<ChatMessage> _history = [];

  GenkitLlmProvider({DatabaseHelper? dbHelper, AiService? aiService})
    : _dbHelper = dbHelper ?? DatabaseHelper(),
      _aiService = aiService ?? GenkitAiService() {
    _init();
  }

  Future<void> _init() async {
    await _aiService.init();
    _loadMessages();
  }

  void _loadMessages() {
    final rawMessages = _dbHelper.getMessages();
    _history.clear();
    for (final m in rawMessages) {
      if (m['role'] == 'user') {
        _history.add(ChatMessage.user(m['content'] as String, []));
      } else {
        final llmMsg = ChatMessage.llm();
        llmMsg.append(m['content'] as String);
        _history.add(llmMsg);
      }
    }
    notifyListeners();
  }

  @override
  Stream<String> generateStream(
    String prompt, {
    Iterable<Attachment>? attachments,
  }) async* {
    final historyMap = _history
        .map(
          (m) => {
            'role': m.origin.isUser ? 'user' : 'system',
            'content': m.text ?? '',
          },
        )
        .toList();

    final response = await _aiService.sendMessage(prompt, historyMap);

    if (response['success'] == true) {
      yield response['text'] as String;
    } else {
      throw Exception(response['error']);
    }
  }

  @override
  Stream<String> sendMessageStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) async* {
    // Save user message to DB
    _dbHelper.insertMessage('user', prompt);

    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();

    _history.addAll([userMessage, llmMessage]);
    notifyListeners();

    try {
      String fullResponse = '';
      final responseStream = generateStream(prompt, attachments: attachments);

      await for (final chunk in responseStream) {
        fullResponse += chunk;
        llmMessage.append(chunk);
        yield chunk;
      }

      // Save AI message to DB after it finishes
      _dbHelper.insertMessage('system', fullResponse);
    } catch (e) {
      llmMessage.append('Error: $e');
      _dbHelper.insertMessage('system', 'Error: $e');
      yield 'Error: $e';
    }

    notifyListeners();
  }

  @override
  Iterable<ChatMessage> get history => _history;

  @override
  set history(Iterable<ChatMessage> history) {
    _history.clear();
    _history.addAll(history);
    notifyListeners();
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }
}
