import 'dart:isolate';

import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';

class GenkitRequest {
  final String prompt;
  final List<Map<String, dynamic>> history;

  GenkitRequest(this.prompt, this.history);
}

class GenkitIsolate {
  static Future<SendPort> init() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntry, receivePort.sendPort);
    return await receivePort.first as SendPort;
  }

  static void _isolateEntry(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    // Initialize Genkit
    final ai = Genkit(plugins: [googleAI()]);

    port.listen((message) async {
      if (message == 'close') {
        port.close();
        return;
      }

      if (message is List) {
        final SendPort replyPort = message[0];
        final GenkitRequest request = message[1];

        try {
          final history = request.history
              .map(
                (m) => Message(
                  role: m['role'] == 'user' ? Role.user : Role.model,
                  content: [TextPart(text: m['content'] as String)],
                ),
              )
              .toList();

          final reqMessages = [
            ...history,
            Message(
              role: Role.user,
              content: [TextPart(text: request.prompt)],
            ),
          ];

          final response = await ai.generate(
            model: googleAI.gemini('gemini-1.5-flash'),
            messages: reqMessages,
          );

          replyPort.send({'success': true, 'text': response.text});
        } catch (e) {
          replyPort.send({'success': false, 'error': e.toString()});
        }
      }
    });
  }
}
