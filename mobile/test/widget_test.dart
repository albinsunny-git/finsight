import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finsight_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences for SplashScreen
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FinsightApp());

    // Verify that the splash screen shows the title.
    expect(find.text('FinSight'), findsOneWidget);
    expect(find.byIcon(Icons.auto_graph), findsOneWidget);

    // Wait for the splash screen animation and timer (3 seconds)
    await tester
        .pump(const Duration(seconds: 4)); // Wait slightly longer than 3s
    await tester.pump(); // Complete navigation frame

    // Verify that we navigated to LoginScreen (since no user data in mocked prefs)
    // LoginScreen has 'Sign In' button and 'FinSight' text.
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('FinSight'), findsOneWidget);
  });
}
