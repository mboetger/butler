import 'package:flutter/foundation.dart';

import '../db.dart';
import '../services/ai_service.dart';

class ChatViewModel extends ChangeNotifier {
  final DatabaseHelper _dbHelper;
  final AiService _aiService;

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatViewModel({DatabaseHelper? dbHelper, AiService? aiService})
    : _dbHelper = dbHelper ?? DatabaseHelper(),
      _aiService = aiService ?? GenkitAiService() {
    _init();
  }

  Future<void> _init() async {
    _loadMessages();
    await _aiService.init();
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }

  void _loadMessages() {
    _messages = _dbHelper.getMessages();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final prompt = text.trim();

    _dbHelper.insertMessage('user', prompt);
    _loadMessages();

    _isLoading = true;
    notifyListeners();

    final history = _messages
        .where((m) => m['role'] == 'user' || m['role'] == 'model')
        .toList();

    final response = await _aiService.sendMessage(prompt, history);

    if (response['success'] == true) {
      _dbHelper.insertMessage('model', response['text'] as String);
    } else {
      _dbHelper.insertMessage('system', 'Error: ${response["error"]}');
    }

    _isLoading = false;
    _loadMessages();
  }
}
