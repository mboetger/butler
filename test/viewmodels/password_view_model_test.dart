import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:butler/db.dart';
import 'package:butler/viewmodels/password_view_model.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  late PasswordViewModel viewModel;
  late MockDatabaseHelper mockDbHelper;

  setUp(() {
    mockDbHelper = MockDatabaseHelper();
    when(() => mockDbHelper.doesDatabaseExist()).thenAnswer((_) async => true);
    viewModel = PasswordViewModel(dbHelper: mockDbHelper);
  });

  group('PasswordViewModel', () {
    test('initializes correctly', () async {
      // Allow async init to finish
      await Future.delayed(Duration.zero);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.dbExists, isTrue);
      expect(viewModel.error, isNull);
    });

    test('submit with empty password returns false', () async {
      final success = await viewModel.submit('');
      expect(success, isFalse);
    });

    test('submit with correct password sets success state', () async {
      when(() => mockDbHelper.init(any())).thenAnswer((_) async => true);
      
      final success = await viewModel.submit('correct_password');
      
      expect(success, isTrue);
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.error, isNull);
    });

    test('submit with incorrect password sets error state', () async {
      when(() => mockDbHelper.init(any())).thenAnswer((_) async => false);
      
      final success = await viewModel.submit('wrong_password');
      
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, 'Incorrect password. Please try again.');
    });
  });
}
