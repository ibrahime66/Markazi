import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markazi/l10n/app_localizations.dart';
import 'package:markazi/utils/app_exception.dart';

/// doc/audit.md, point K8 — traduction de l'app (français, anglais, arabe).
Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _placeholders(String text) =>
    RegExp(r'\{(\w+)\}').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  test('les trois langues ont exactement les mêmes clés et les mêmes variables', () {
    final fr = _arb('fr');
    final keys = fr.keys.where((k) => !k.startsWith('@')).toSet();
    for (final lang in ['en', 'ar']) {
      final other = _arb(lang);
      final otherKeys = other.keys.where((k) => !k.startsWith('@')).toSet();
      expect(otherKeys.difference(keys), isEmpty, reason: 'clés en trop dans $lang');
      expect(keys.difference(otherKeys), isEmpty, reason: 'clés manquantes dans $lang');
      for (final key in keys) {
        expect(
          _placeholders(other[key] as String),
          _placeholders(fr[key] as String),
          reason: 'variables différentes pour "$key" en $lang',
        );
        expect((other[key] as String).trim(), isNotEmpty, reason: '"$key" vide en $lang');
      }
    }
  });

  test('une erreur métier est affichée dans la langue active, sans préfixe technique', () {
    final error = AppException((l) => l.errStudentNotFound);

    AppLocale.current = const Locale('fr');
    expect(error.toString(), 'Élève non trouvé');
    AppLocale.current = const Locale('en');
    expect(error.toString(), 'Student not found');
    AppLocale.current = const Locale('ar');
    expect(error.toString(), 'الطالب غير موجود');

    AppLocale.current = const Locale('en');
    expect(AppException((l) => l.errGroupFull(30)).toString(),
        'The group is already full (30 students)');
    AppLocale.current = const Locale('fr');
  });

  testWidgets('en arabe, l’interface est traduite et s’affiche de droite à gauche',
      (tester) async {
    late TextDirection direction;
    late String title;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(builder: (context) {
        direction = Directionality.of(context);
        title = AppLocalizations.of(context).navActivityLog;
        return const SizedBox();
      }),
    ));

    expect(direction, TextDirection.rtl);
    expect(title, 'سجل النشاط');
  });
}
