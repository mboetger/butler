import 'dart:isolate';

import '../genkit_isolate.dart';

abstract class AiService {
  Future<void> init();
  Future<Map<String, dynamic>> sendMessage(
    String prompt,
    List<Map<String, dynamic>> history,
  );
  void dispose();
}

class GenkitAiService implements AiService {
  SendPort? _genkitPort;

  @override
  Future<void> init() async {
    _genkitPort = await GenkitIsolate.init();
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    String prompt,
    List<Map<String, dynamic>> history,
  ) async {
    if (_genkitPort == null) {
      return {'success': false, 'error': 'Not initialized'};
    }
    final responsePort = ReceivePort();
    _genkitPort!.send([responsePort.sendPort, GenkitRequest(prompt, history)]);
    return await responsePort.first as Map<String, dynamic>;
  }

  @override
  void dispose() {
    _genkitPort?.send('close');
  }
}
