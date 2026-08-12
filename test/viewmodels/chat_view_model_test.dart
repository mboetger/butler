import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:butler/db.dart';
import 'package:butler/services/ai_service.dart';
import 'package:butler/viewmodels/chat_view_model.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockAiService extends Mock implements AiService {}

void main() {
  late ChatViewModel viewModel;
  late MockDatabaseHelper mockDbHelper;
  late MockAiService mockAiService;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    mockAiService = MockAiService();

    when(() => mockDbHelper.getMessages()).thenReturn([]);
    when(() => mockAiService.init()).thenAnswer((_) async {});

    viewModel = ChatViewModel(dbHelper: mockDbHelper, aiService: mockAiService);
  });

  group('ChatViewModel', () {
    test('initializes correctly and loads messages', () async {
      await Future.delayed(Duration.zero);
      verify(() => mockDbHelper.getMessages()).called(1);
      verify(() => mockAiService.init()).called(1);
      expect(viewModel.messages, isEmpty);
      expect(viewModel.isLoading, isFalse);
    });

    test('sendMessage sends message and updates db', () async {
      await Future.delayed(Duration.zero); // Let init finish

      when(() => mockAiService.sendMessage(any(), any()))
          .thenAnswer((_) async => {'success': true, 'text': 'Hello from AI!'});

      final future = viewModel.sendMessage('Hello!');

      // Right after calling sendMessage, it should be loading
      expect(viewModel.isLoading, isTrue);

      await future;

      verify(() => mockDbHelper.insertMessage('user', 'Hello!')).called(1);
      verify(() => mockDbHelper.insertMessage('model', 'Hello from AI!'))
          .called(1);

      // Should call getMessages 3 times: once on init, once on user send, once on AI reply
      verify(() => mockDbHelper.getMessages()).called(3);
      expect(viewModel.isLoading, isFalse);
    });

    test('sendMessage handles error gracefully', () async {
      await Future.delayed(Duration.zero);

      when(() => mockAiService.sendMessage(any(), any()))
          .thenAnswer((_) async => {'success': false, 'error': 'API Error'});

      await viewModel.sendMessage('Hello!');

      verify(() => mockDbHelper.insertMessage('user', 'Hello!')).called(1);
      verify(() => mockDbHelper.insertMessage('system', 'Error: API Error'))
          .called(1);
      expect(viewModel.isLoading, isFalse);
    });

    test('sendMessage ignores empty text', () async {
      await viewModel.sendMessage('   ');

      verifyNever(() => mockDbHelper.insertMessage(any(), any()));
      verifyNever(() => mockAiService.sendMessage(any(), any()));
    });
  });
}
