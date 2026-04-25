import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markazi/main.dart';

void main() {
  testWidgets('Markazi app launches and displays splash screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MarkaziApp());

    // Verify that the splash screen is displayed
    expect(find.text('Markazi'), findsWidgets);
    expect(find.text('Gérez votre markaz\nsimplement et efficacement'),
        findsOneWidget);

    // Verify that the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Navigation to onboarding screen works',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MarkaziApp());

    // Wait for the splash screen animation and navigation
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify we're on the onboarding screen
    expect(find.text('Gérez vos élèves\nfacilement'), findsOneWidget);
  });
}
