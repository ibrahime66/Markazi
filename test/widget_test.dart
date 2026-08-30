import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:markazi/main.dart';
import 'package:markazi/services/auth_service.dart';

/// [AuthService] réel, sans session restaurée : `SplashScreen` s'en sert
/// uniquement pour lire `isAuthenticated` (toujours faux ici) et choisir
/// vers quel écran naviguer — aucun appel réseau n'est déclenché par ce test.
///
/// Correctif (doc/audit.md, point E2) : ce test échouait déjà avant toute
/// modification de cette session, avec deux causes distinctes :
/// 1. `MarkaziApp` seul (sans le `MultiProvider` que `main()` met en place)
///    ne fournit pas l'`AuthService` que `SplashScreen` lit via
///    `context.read` — l'app plantait faute de Provider ancestor.
/// 2. Le premier test ne laissait jamais les timers de `_startAnimations`
///    (plusieurs `Future.delayed`) se terminer avant la fin du test, ce que
///    le framework de test rejette ("Pending timers").
Widget _wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      Provider<AuthService>(create: (_) => AuthService()),
    ],
    child: child,
  );
}

void main() {
  testWidgets('Markazi app launches and displays splash screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(_wrapWithProviders(const MarkaziApp()));

    // Verify that the splash screen is displayed
    expect(find.text('Markazi'), findsWidgets);
    expect(find.text('Gérez votre markaz\nsimplement et efficacement'),
        findsOneWidget);

    // Verify that the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Laisser les animations/timers de la splash screen se terminer
    // (navigation incluse) pour ne pas finir le test avec des timers en
    // attente.
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });

  testWidgets('Navigation to onboarding screen works',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrapWithProviders(const MarkaziApp()));

    // Wait for the splash screen animation and navigation
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify we're on the onboarding screen
    expect(find.text('Gérez vos élèves\nfacilement'), findsOneWidget);
  });
}
