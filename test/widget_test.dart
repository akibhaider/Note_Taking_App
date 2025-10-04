import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import using package name for tests
import 'package:one_note_clone/app.dart';

void main() {
  testWidgets('Notes app home page test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Wait for the app to load
    await tester.pumpAndSettle();

    // Verify that the home page loads with expected text
    expect(find.text('Welcome to Notes App'), findsOneWidget);
    expect(find.text('View Notes'), findsOneWidget);
    expect(find.text('Create New Note'), findsOneWidget);

    // Verify that the buttons are present
    expect(find.byIcon(Icons.list_alt), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Theme toggle test', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap the theme toggle button
    final themeButton = find.byIcon(Icons.dark_mode);
    expect(themeButton, findsOneWidget);

    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    // After toggling, the icon should change to light_mode
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('Navigation to create note page test', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap the Create New Note button
    final createButton = find.text('Create New Note');
    expect(createButton, findsOneWidget);

    await tester.tap(createButton);
    await tester.pumpAndSettle();

    // Verify navigation to create note page
    expect(find.text('Create Note'), findsOneWidget);
    expect(find.text('Title'), findsOneWidget);
  });
}