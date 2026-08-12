import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:butler/viewmodels/password_view_model.dart';
import 'package:butler/views/password_view.dart';

class MockPasswordViewModel extends Mock implements PasswordViewModel {
  @override
  void addListener(VoidCallback listener) {}
  
  @override
  void removeListener(VoidCallback listener) {}
  
  @override
  void dispose() {}
}

void main() {
  late MockPasswordViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockPasswordViewModel();
    // Default mock behavior
    when(() => mockViewModel.isLoading).thenReturn(false);
    when(() => mockViewModel.dbExists).thenReturn(false);
    when(() => mockViewModel.error).thenReturn(null);
  });

  Widget buildSubject(PasswordViewModel vm) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: PasswordScreen(viewModel: vm),
      ),
    );
  }

  testWidgets('PasswordScreen renders "Create Database" state correctly', (WidgetTester tester) async {
    when(() => mockViewModel.dbExists).thenReturn(false);
    
    await tester.pumpWidget(buildSubject(mockViewModel));
    // Provide some time for any microtasks
    await tester.pump(const Duration(milliseconds: 100)); 
    
    expect(find.text('Secure Database'), findsOneWidget);
    
    await expectLater(
      find.byType(PasswordScreen),
      matchesGoldenFile('goldens/password_screen_create.png'),
    );
  });

  testWidgets('PasswordScreen renders "Unlock Database" state correctly', (WidgetTester tester) async {
    when(() => mockViewModel.dbExists).thenReturn(true);
    
    await tester.pumpWidget(buildSubject(mockViewModel));
    await tester.pump(const Duration(milliseconds: 100));
    
    expect(find.text('Unlock Database'), findsOneWidget);
    
    await expectLater(
      find.byType(PasswordScreen),
      matchesGoldenFile('goldens/password_screen_unlock.png'),
    );
  });

  testWidgets('PasswordScreen renders error state correctly', (WidgetTester tester) async {
    when(() => mockViewModel.dbExists).thenReturn(true);
    when(() => mockViewModel.error).thenReturn('Incorrect password. Please try again.');
    
    await tester.pumpWidget(buildSubject(mockViewModel));
    await tester.pump(const Duration(milliseconds: 100));
    
    await expectLater(
      find.byType(PasswordScreen),
      matchesGoldenFile('goldens/password_screen_error.png'),
    );
  });
}
