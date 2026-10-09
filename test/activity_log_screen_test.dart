import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:markazi/datasources/api_activity_log_datasource.dart';
import 'package:markazi/l10n/app_localizations.dart';
import 'package:markazi/models/activity_log_entry.dart';
import 'package:markazi/providers/activity_log_provider.dart';
import 'package:markazi/providers/locale_provider.dart';
import 'package:markazi/providers/theme_provider.dart';
import 'package:markazi/screens/activity_log_screen.dart';

/// doc/audit.md, point F4 — écran "Journal d'activité".
class _FakeDatasource extends Fake implements ApiActivityLogDatasource {
  final List<String?> requestedCategories = [];

  @override
  Future<ActivityLogPage> fetchPage({
    int page = 1,
    int perPage = 30,
    String? category,
    DateTime? dateFrom,
  }) async {
    requestedCategories.add(category);
    final now = DateTime.now().toUtc().toIso8601String();
    return ActivityLogPage(
      currentPage: 1,
      lastPage: 1,
      entries: [
        ActivityLogEntry.fromJson({
          'id': 1,
          'action': 'payment.recorded',
          'description': 'Paiement enregistré',
          'performed_at': now,
          'user': {'name': 'Oustaz Mamadou'},
          'meta': {'synced_offline': true},
        }),
        ActivityLogEntry.fromJson({
          'id': 2,
          'action': 'sync.conflict',
          'description': 'Conflit de synchronisation (Guardian #3)',
          'performed_at': now,
          'meta': {
            'subject': 'Guardian #3',
            'operation': 'update',
            'performed_at': now,
            'server_updated_at': now,
            'overwritten_server_version': {'name': 'Version serveur'},
          },
        }),
      ],
    );
  }
}

void main() {
  testWidgets('affiche les entrées, le badge hors ligne et le détail d’un conflit',
      (tester) async {
    final datasource = _FakeDatasource();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ActivityLogProvider(datasource)),
        ],
        child: const MaterialApp(
          locale: Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ActivityLogScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Aujourd'hui"), findsOneWidget);
    expect(find.text('Paiement enregistré'), findsOneWidget);
    expect(find.text('Saisi hors ligne'), findsOneWidget);
    expect(find.textContaining('Oustaz Mamadou'), findsOneWidget);

    await tester.tap(find.text('Conflit de synchronisation : Guardian #3'));
    await tester.pumpAndSettle();
    expect(find.text('Conflit de synchronisation'), findsOneWidget);
    expect(find.text('name : Version serveur'), findsOneWidget);
    await tester.tap(find.text('Fermer'));
    await tester.pumpAndSettle();

    // Le filtre de catégorie relance une requête avec la bonne catégorie.
    await tester.dragUntilVisible(
      find.text('Paiements'),
      find.byType(ListView).first,
      const Offset(-150, 0),
    );
    await tester.tap(find.text('Paiements'));
    await tester.pumpAndSettle();
    expect(datasource.requestedCategories.last, 'payment');
  });
}
