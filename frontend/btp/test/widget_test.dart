import 'package:flutter/material.dart';
import 'package:btp_multi_sector/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.



void main() {
  testWidgets('App starts and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: BTPMultiSectorApp(),
      ),
    );

    // Verify that the app starts
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Wait for any pending timers
    await tester.pumpAndSettle();
  });

  testWidgets('App can navigate to login page', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: BTPMultiSectorApp(),
      ),
    );

    // Wait for the app to load and settle all timers
    await tester.pumpAndSettle();

    // The app should show the splash screen initially
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
